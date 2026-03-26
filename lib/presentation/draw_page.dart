import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:painter/painter.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/widgets/letter_tracer_widget.dart';
import 'package:tibetan_language_learning_app/widgets/trace_mode_toggle.dart';

/// Drawing page that supports both free draw and guided trace modes
class DrawingPage extends StatefulWidget {
  final Alphabet? alphabet;
  final bool initialTraceMode;

  const DrawingPage({
    Key? key,
    this.alphabet,
    this.initialTraceMode = false,
  }) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  bool _finished = false;
  PainterController _controller = _newController();
  bool _isTraceMode = false;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _isTraceMode = widget.initialTraceMode;
  }

  void _onModeChanged(bool isTraceMode) {
    setState(() {
      _isTraceMode = isTraceMode;
    });
  }

  void _onFeedback(String message) {
    setState(() {
      _feedbackMessage = message;
    });
    // Clear feedback after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  static PainterController _newController() {
    PainterController controller = PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.white;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            // Mode toggle (only show if alphabet is provided)
            if (widget.alphabet != null)
              _buildModeToggle(),

            // Main content
            Expanded(
              child: _isTraceMode
                  ? _buildTraceMode()
                  : _buildFreeDrawMode(),
            ),

            // Feedback message
            if (_feedbackMessage != null)
              _buildFeedbackMessage(),
          ],
        ),
      ),
      bottomNavigationBar: _isTraceMode ? null : _buildButtons(),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Mode:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          InlineTraceModeToggle(
            isTraceMode: _isTraceMode,
            onChanged: _onModeChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFreeDrawMode() {
    return Column(
      children: [
        PreferredSize(
          child: DrawBar(_controller),
          preferredSize: Size(MediaQuery.of(context).size.width, 30.0),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Painter(_controller),
          ),
        ),
      ],
    );
  }

  Widget _buildTraceMode() {
    if (widget.alphabet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No alphabet selected',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onModeChanged(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('Switch to Free Draw'),
            ),
          ],
        ),
      );
    }

    return LetterTracerWidget(
      alphabet: widget.alphabet!,
      onComplete: () {
        _onFeedback('Letter complete! Great job!');
      },
      onStrokeComplete: () {
        // Stroke completed
      },
      onProgressChanged: (progress) {
        // Progress updated
      },
      onFeedback: _onFeedback,
    );
  }

  Widget _buildFeedbackMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _feedbackMessage!,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _show(PictureDetails picture, BuildContext context) {
    setState(() {
      _finished = true;
    });
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View your image'),
        ),
        body: Container(
            alignment: Alignment.center,
            child: FutureBuilder<Uint8List>(
              future: picture.toPNG(),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Image.memory(snapshot.data!);
                    }
                  default:
                    return Container(
                        child: FractionallySizedBox(
                      widthFactor: 0.1,
                      child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CircularProgressIndicator()),
                      alignment: Alignment.center,
                    ));
                }
              },
            )),
      );
    }));
  }

  Widget _buildButtons() {
    if (_finished) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.content_copy),
              tooltip: 'New Painting',
              onPressed: () => setState(() {
                _finished = false;
                _controller = _newController();
              }),
            ),
          ],
        ),
      );
    }
    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          IconButton(
              icon: Icon(
                Icons.undo,
                color: Colors.white,
              ),
              tooltip: 'Undo',
              onPressed: () {
                if (_controller.isEmpty) {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) =>
                          Text('Nothing to undo'));
                } else {
                  _controller.undo();
                }
              }),
          IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Clear',
              color: Colors.white,
              onPressed: _controller.clear),
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () => _show(_controller.finish(), context),
          ),
        ],
      ),
    );
  }
}

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              child: Slider(
            value: _controller.thickness,
            onChanged: (double value) => setState(() {
              _controller.thickness = value;
            }),
            min: 1.0,
            max: 20.0,
            activeColor: Colors.white,
          ));
        })),
        StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return RotatedBox(
              quarterTurns: _controller.eraseMode ? 2 : 0,
              child: IconButton(
                  icon: Icon(
                    Icons.create,
                    color: Colors.white,
                  ),
                  tooltip: (_controller.eraseMode ? 'Disable' : 'Enable') +
                      ' eraser',
                  onPressed: () {
                    setState(() {
                      _controller.eraseMode = !_controller.eraseMode;
                    });
                  }));
        }),
        ColorPickerButton(_controller, false),
        ColorPickerButton(_controller, true),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final PainterController _controller;
  final bool _background;

  ColorPickerButton(this._controller, this._background);

  @override
  _ColorPickerButtonState createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(_iconData, color: _color),
        tooltip: widget._background
            ? 'Change background color'
            : 'Change draw color',
        onPressed: _pickColor);
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator.of(context)
        .push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Scaffold(
                  appBar: AppBar(
                    title: const Text('Pick color'),
                  ),
                  body: Container(
                      alignment: Alignment.center,
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: (Color c) => pickerColor = c,
                      )));
            }))
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => widget._background
      ? widget._controller.backgroundColor
      : widget._controller.drawColor;

  IconData get _iconData =>
      widget._background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    if (widget._background) {
      widget._controller.backgroundColor = color;
    } else {
      widget._controller.drawColor = color;
    }
  }
}
