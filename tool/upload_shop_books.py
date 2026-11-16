#!/usr/bin/env python3
"""Publishes the Shop's books: pictures to Firebase Storage, books to Firestore.

1. Pictures. A `cover` or `previews` entry in assets/books/books.json that is
   a file name (not yet an https link) is a picture in tool/shop_pictures/.
   It is uploaded to Firebase Storage (shop_books/<file name>), and its entry
   in books.json is replaced by the picture's download link.
2. Books. Each book becomes one document in the Firestore collection
   `shop_books`, named by its id, with an `order` number that keeps the books
   in file order. A book that is already there is replaced. Books in Firestore
   but not in the file are left alone, unless you pass --prune, which deletes
   them.

    python3 tool/upload_shop_books.py --dry-run           # show what would change
    python3 tool/upload_shop_books.py                     # publish
    python3 tool/upload_shop_books.py --prune             # publish, and delete removed books

To replace a picture, put the new file in tool/shop_pictures/ and write its
file name back in place of the link; it gets a new link, so phones fetch it
again. See docs/shop-books.md.

Uses your gcloud login (`gcloud auth login`) and the Firebase project in
android/app/google-services.json.
"""

import argparse
import base64
import hashlib
import json
import mimetypes
import pathlib
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid

ROOT = pathlib.Path(__file__).resolve().parent.parent
BOOKS = ROOT / "assets/books/books.json"
PICTURES = ROOT / "tool/shop_pictures"
COLLECTION = "shop_books"
STORAGE_FOLDER = "shop_books"


def firestore_value(value):
    """A JSON value in Firestore's REST format."""
    if value is None:
        return {"nullValue": None}
    if isinstance(value, bool):
        return {"booleanValue": value}
    if isinstance(value, int):
        return {"integerValue": str(value)}
    if isinstance(value, float):
        return {"doubleValue": value}
    if isinstance(value, str):
        return {"stringValue": value}
    if isinstance(value, list):
        return {"arrayValue": {"values": [firestore_value(v) for v in value]}}
    if isinstance(value, dict):
        return {"mapValue": {"fields": {k: firestore_value(v) for k, v in value.items()}}}
    raise TypeError(f"can't store {value!r} in Firestore")


def documents(data):
    """(id, fields) for each book, in order."""
    books = data["books"] if isinstance(data, dict) else data
    docs = []
    for position, book in enumerate(books, start=1):
        book = dict(book)
        book_id = str(book.pop("id", "")).strip()
        if not book_id or not str(book.get("title", "")).strip():
            print(f"skipping entry {position}: it needs an id and a title", file=sys.stderr)
            continue
        if "/" in book_id:
            sys.exit(f"book id {book_id!r} can't contain '/'")
        book["order"] = position * 10
        docs.append((book_id, book))
    return docs


def pictures_to_upload(data):
    """(book, field, index, file) for every picture that is still a file name."""
    found = []
    for book in data["books"]:
        slots = [("cover", None, book.get("cover") or "")]
        slots += [("previews", i, p) for i, p in enumerate(book.get("previews") or [])]
        for field, index, value in slots:
            value = value.strip()
            if not value or value.startswith("https://"):
                continue
            path = PICTURES / pathlib.Path(value).name
            if not path.is_file():
                sys.exit(f"{book.get('id')}: picture {value!r} is not in tool/shop_pictures/")
            found.append((book, field, index, path))
    return found


class Firebase:
    def __init__(self, project):
        self.project = project
        self.bucket = f"{project}.firebasestorage.app"
        self.token = subprocess.run(
            ["gcloud", "auth", "print-access-token"], check=True, capture_output=True, text=True
        ).stdout.strip()

    def call(self, method, url, body=None, content_type="application/json", missing_ok=False):
        if isinstance(body, (dict, list)):
            body = json.dumps(body).encode()
        request = urllib.request.Request(
            url,
            data=body,
            method=method,
            headers={
                "Authorization": f"Bearer {self.token}",
                "x-goog-user-project": self.project,
                "Content-Type": content_type,
            },
        )
        try:
            return json.loads(urllib.request.urlopen(request).read() or b"{}")
        except urllib.error.HTTPError as error:
            if missing_ok and error.code == 404:
                return None
            sys.exit(f"{method} {url}: {error.code} {error.read().decode()[:300]}")

    def upload(self, path):
        """Uploads a picture (unless the same file is already there) and returns its link."""
        name = f"{STORAGE_FOLDER}/{path.name}"
        quoted = urllib.parse.quote(name, safe="")
        content = path.read_bytes()
        md5 = base64.b64encode(hashlib.md5(content).digest()).decode()
        existing = self.call(
            "GET", f"https://storage.googleapis.com/storage/v1/b/{self.bucket}/o/{quoted}", missing_ok=True
        )
        tokens = ((existing or {}).get("metadata") or {}).get("firebaseStorageDownloadTokens", "")
        if existing and existing.get("md5Hash") == md5 and tokens:
            token = tokens.split(",")[0]
        else:
            # A new link for new content, so phones don't keep the old picture.
            token = str(uuid.uuid4())
            meta = {
                "name": name,
                "contentType": mimetypes.guess_type(path.name)[0] or "application/octet-stream",
                "cacheControl": "public, max-age=31536000",
                "metadata": {"firebaseStorageDownloadTokens": token},
            }
            boundary = uuid.uuid4().hex
            body = (
                f"--{boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n"
                f"{json.dumps(meta)}\r\n--{boundary}\r\nContent-Type: {meta['contentType']}\r\n\r\n"
            ).encode() + content + f"\r\n--{boundary}--\r\n".encode()
            self.call(
                "POST",
                f"https://storage.googleapis.com/upload/storage/v1/b/{self.bucket}/o?uploadType=multipart",
                body,
                content_type=f"multipart/related; boundary={boundary}",
            )
        return (
            f"https://firebasestorage.googleapis.com/v0/b/{self.bucket}/o/{quoted}"
            f"?alt=media&token={token}"
        )


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--dry-run", action="store_true", help="show what would change, change nothing")
    parser.add_argument("--prune", action="store_true", help="delete books that are no longer in books.json")
    args = parser.parse_args()

    project = json.loads((ROOT / "android/app/google-services.json").read_text())["project_info"]["project_id"]
    data = json.loads(BOOKS.read_text(encoding="utf-8"))
    pictures = pictures_to_upload(data)
    firebase = None if args.dry_run and not args.prune else Firebase(project)
    base = f"https://firestore.googleapis.com/v1/projects/{project}/databases/(default)/documents"

    stale = []
    if args.prune:
        listed = firebase.call("GET", f"{base}/{COLLECTION}?pageSize=300&mask.fieldPaths=title")
        keep = {book_id for book_id, _ in documents(data)}
        stale = [d["name"].rsplit("/", 1)[1] for d in listed.get("documents", [])]
        stale = [book_id for book_id in stale if book_id not in keep]

    if args.dry_run:
        for book, field, index, path in pictures:
            print(f"would upload {path.relative_to(ROOT)} for {book['id']} ({field})")
        for book_id, fields in documents(data):
            print(f"would write {COLLECTION}/{book_id}: {fields.get('title')}")
        for book_id in stale:
            print(f"would delete {COLLECTION}/{book_id} (not in books.json)")
        return

    for book, field, index, path in pictures:
        link = firebase.upload(path)
        if index is None:
            book[field] = link
        else:
            book[field][index] = link
        print(f"uploaded {path.relative_to(ROOT)}")
    if pictures:
        BOOKS.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"put {len(pictures)} picture links in {BOOKS.relative_to(ROOT)}")

    docs = documents(data)
    for book_id, fields in docs:
        url = f"{base}/{COLLECTION}/{urllib.parse.quote(book_id)}"
        firebase.call("PATCH", url, {"fields": {k: firestore_value(v) for k, v in fields.items()}})
        print(f"wrote {COLLECTION}/{book_id}")
    for book_id in stale:
        firebase.call("DELETE", f"{base}/{COLLECTION}/{urllib.parse.quote(book_id)}")
        print(f"deleted {COLLECTION}/{book_id} (not in books.json)")
    print(f"\n{len(docs)} books published to {project}" + (f", {len(stale)} deleted." if stale else "."))


if __name__ == "__main__":
    main()
