import 'package:flutter/material.dart';

class NewPlaylistModal extends StatefulWidget {
  final Function(String) onCreate;
  const NewPlaylistModal({super.key, required this.onCreate});

  @override
  _NewPlaylistModalState createState() => _NewPlaylistModalState();
}

class _NewPlaylistModalState extends State<NewPlaylistModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9, // 화면의 90% 높이로 설정
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소', style: TextStyle(fontSize: 18.0, color: Colors.red)),
                ),
                Text(
                  '새 재생목록',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _isButtonEnabled
                      ? () {
                    widget.onCreate(_controller.text);
                    Navigator.pop(context);
                  }
                      : null,
                  child: Text('생성', style: TextStyle(fontSize: 18.0)),
                ),
              ],
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '재생목록 제목',
              ),
            ),
            // 다른 UI 요소 추가 가능
          ],
        ),
      ),
    );
  }
}