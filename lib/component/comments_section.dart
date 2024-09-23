import 'package:flutter/material.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = []; // 댓글 리스트

  void _addComment() {
    final text = _commentController.text;
    if (text.isNotEmpty) {
      setState(() {
        comments.add(text);
        _commentController.clear();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return                       Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: '댓글을 입력해주세요',
                  ),
                ),
              ),
              SizedBox(width:8),
              ElevatedButton(
                onPressed: _addComment,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0abf00),
                    minimumSize: Size(80,55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )

                ),
                child: Text(
                  '저장',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NotoSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500

                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(comments[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}
