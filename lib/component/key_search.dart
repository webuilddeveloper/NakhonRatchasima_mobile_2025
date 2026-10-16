import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';

class KeySearch extends StatefulWidget {
  KeySearch(
      {super.key, this.show, this.onKeySearchChange, required this.hintext});

//  final VoidCallback onTabCategory;
  final bool? show;
  final Function(String)? onKeySearchChange;
  final String hintext;

  @override
  _SearchBox createState() =>
      _SearchBox(show: show!, onKeySearchChange: onKeySearchChange!);
}

class _SearchBox extends State<KeySearch> {
  final txtDescription = TextEditingController();
  bool? show;
  Function(String)? onKeySearchChange;

  _SearchBox({@required this.show, this.onKeySearchChange});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    txtDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                autofocus: false,
                cursorColor: Theme.of(context).primaryColor,
                controller: txtDescription,
                onChanged: (text) {
                  onKeySearchChange!(txtDescription.text);
                  setState(() {});
                },
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: widget.hintext,
                    suffixIcon: txtDescription.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              txtDescription.clear();
                              onKeySearchChange!('');
                              setState(() {});
                            },
                          ),
                    contentPadding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                onKeySearchChange!(txtDescription.text);
                setState(() {
                  show = !show!;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/search.png',
                  height: 20.0,
                  width: 20.0,
                ),
              ),
            )
          ],
        ));
  }
}
