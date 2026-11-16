# Shop books

The Shop's books and their pictures live online, so you can add, change,
reorder or remove a book at any time **without releasing the app**:

- **Books** are in Firestore: collection `shop_books` in the
  `tibetanlanguagelearningapp` project's `(default)` database, one document per
  book.
- **Pictures** (covers and inside pages) are in Firebase Storage, in the
  `shop_books/` folder. Phones download each picture once and keep it.
- Phones keep the last book list they downloaded, so the Shop opens straight
  away and works offline. They ask Firestore again at most **once an hour**, and
  if anything changed, the new list replaces the old one on screen.

You edit one file, `assets/books/books.json`, and publish it with one command:

```
python3 tool/upload_shop_books.py --dry-run   # see what would change
python3 tool/upload_shop_books.py             # publish
```

It uses your `gcloud` login (`gcloud auth login` if it asks).

`books.json` is also built into the app. It is shown the very first time the
Shop opens, before Firestore has answered, so new phones never see an empty
Shop.

## Add a book

1. Put its pictures in `tool/shop_pictures/`. That folder isn't part of the
   app; it's where the upload script finds new pictures.
   - Cover: `<id>-cover.jpg`, about 800 px wide, without bleed.
   - Inside pages: `<id>-page-1.jpg`, `<id>-page-2.jpg`, …, three to five of
     them, about 1000 px wide. Readers swipe through and zoom into these.
   - JPG at about 80% quality, so each picture is 60–110 KB.
2. In `books.json`, copy an existing book and fill it in (fields below). For the
   pictures, write just the file names:

   ```json
   "cover": "my-new-book-cover.jpg",
   "previews": ["my-new-book-page-1.jpg", "my-new-book-page-2.jpg"],
   ```

   Books appear in the order they're listed in the file.
3. Run `python3 tool/upload_shop_books.py`. It uploads the new pictures to
   Storage, replaces the file names in `books.json` with their web links, and
   publishes the books.

## Change a book

Edit it in `books.json` and run the upload script.

To replace a picture, put the new file in `tool/shop_pictures/` and write its
file name back in place of the old link. The new picture gets a new link, so
phones download it again instead of keeping the old one.

## Remove a book

Delete it from `books.json` and run:

```
python3 tool/upload_shop_books.py --prune
```

`--prune` deletes books from Firestore that are no longer in the file. With
`--dry-run` it only lists them. To hide a book for a while instead, add
`"hidden": true` to it and publish.

## Editing in the Firebase console instead

You can also edit a book directly in the console (Firestore → `shop_books` →
the book). The next upload replaces those books with what's in `books.json`,
so copy any console changes into the file too. To add a picture by hand, upload
it under Storage → `shop_books/`, open it, and copy the link under **Access
token**.

## How covers are shown

Every cover is shown the same size, in the frame of an 8.5 × 11 in book. A cover
of another shape is shown whole inside that frame, on a soft blur of itself.
Examples are the square picture book, the Kindle-shaped Fruits & Vegetables
cover, and the 6 × 9 in Coloring Book.

## Security rules

Firestore lets anyone read `shop_books` and nobody write to it. The upload
script and the console use your owner login, which the rules don't limit:

```
match /shop_books/{book} {
  allow read: if true;
}
```

Storage rules still block everything. Pictures load through their links'
access tokens, which work regardless of the rules, and nothing else in Storage
is readable.

## Fields

| Field         | Type    | Example                                   | Notes |
|---------------|---------|-------------------------------------------|-------|
| `title`       | string  | `"Trace & Write Tibetan Alphabet"`        | Required. |
| `subtitle`    | string  | `"My first Tibetan writing workbook"`     | Shown under the title. |
| `publisher`   | string  | `"KharagEdition"`                         | Shown under the title and on stand-in covers. |
| `author`      | string  | `""`                                      | Shown only when `publisher` is empty. |
| `badge`       | string  | `"New"`, `"Level 1"`                      | Small label above the title on the book page. One or two words. |
| `description` | string  | `"Learn to write all 30 Tibetan letters…"` | A few sentences for parents. |
| `ages`        | string  | `"3–7"`                                   | Shown as "Ages 3–7". |
| `pages`       | number  | `73`                                      | `0` hides it. |
| `format`      | string  | `"Paperback · 8.5 × 11 in"`               | Keep it short; it sits beside the cover. |
| `cover`       | string  | `"my-book-cover.jpg"` (becomes a link)    | Empty (`""`) shows a plain title card instead. |
| `previews`    | array of strings | file names (become links)   | Inside pages, in order. Can be empty. |
| `links`       | map     | `world`: `"https://www.amazon.com/dp/…"`, `india`: `""` | See below. |
| `order`       | number  | `30`                                      | Set by the upload script from the file order. Only needed for a book added in the console. |
| `hidden`      | boolean | `true`                                    | Leaves the book out of the Shop. |

In `books.json` the book's `id` is a field; in Firestore it's the document ID.
Fields left empty (`""`) are simply not shown.

## Links

Each book has two links:

- `world`: the book on **amazon.com** (`https://www.amazon.com/dp/<code>`).
- `india`: the book's India edition on **amazon.in**. Leave it `""` until that
  edition is on sale. India is the only country that needs its own link.

The app works out which country the reader is in and opens their own Amazon
site, using the book code from the `world` link:

| Reader in | Opens |
|-----------|-------|
| India | the `india` link; if it's empty or won't open, amazon.com |
| Canada, UK, Germany, France, Spain, Italy, Netherlands, Japan, Australia | amazon.ca, amazon.co.uk, amazon.de, amazon.fr, amazon.es, amazon.it, amazon.nl, amazon.co.jp, amazon.com.au, with the same book code |
| US and everywhere else | amazon.com |

If a link won't open, the app tries the amazon.com link next. Amazon can't be
asked whether a page exists (it answers "OK" even for a missing book), so only
fill in the `india` link once that edition is on sale. The list of countries is
`AmazonSites.byCountry` in `lib/model/book_item.dart`.

For a book with a different edition in some other country, add that country's
two-letter code as another link, e.g. `"ca": "https://www.amazon.ca/dp/…"`.

To find the reader's country, the app checks, in order:

1. the mobile network the phone is on (Android). This is where the phone is
   now, even with a SIM card from home;
2. the internet connection, on Wi-Fi or mobile data. The app asks Cloudflare
   (or country.is, if that fails) which country the phone's internet address
   is in;
3. the country it found last time, if neither answers now;
4. the SIM card's country (Android);
5. India's time zone (UTC+5:30), and then the phone's region setting.

The reader only ever sees **Buy on Amazon**; no store is named. The button opens
the Amazon app if it's installed, and otherwise the browser. A book with no
links at all shows **Coming soon**, with the button greyed out.

Any full `https://` Amazon link works for `world`, including links with an
Associates tag (`?tag=yourtag-20`). Short links (`amzn.to`, `a.co`) work too,
but then every country gets that same link, because they don't contain the book
code.
