import 'package:flutter/material.dart';

PreferredSizeWidget header(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonLeft = true,
  bool isButtonRight = false,
  String imageRightButton = 'assets/images/task_list.png',
  Function? rightButton,
  String menu = '',
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      backgroundColor: Color(0xFFe7b014),
      elevation: 0.0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 5,

      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),

      leading: isButtonLeft
          ? Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
              child: InkWell(
                onTap: () => functionGoBack(),
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            )
          : null,

      // Right Button (Optional)
      actions: [
        if (isButtonRight)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
            child: InkWell(
              onTap: () => rightButton?.call(),
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: 42.0,
                height: 42.0,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Image.asset(
                  imageRightButton,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

headerNoti(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonRight = false,
  required Function rightButton,
  String menu = '',
  required int notiCount,
}) {
  return AppBar(
    centerTitle: false,
    flexibleSpace: Container(),
    backgroundColor: Color(0xFFe7b014),
    elevation: 0.0,
    titleSpacing: 5,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
          child: InkWell(
            onTap: () => functionGoBack(),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(12.0),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
              color: Colors.white),
        ),
        SizedBox(width: 15),
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          constraints: BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
          child: Center(
            child: Text(
              notiCount.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kanit',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    ),
    actions: <Widget>[
      isButtonRight == true
          ? menu == 'notification'
              ? Container(
                  child: Container(
                    child: Container(
                      width: 45.0,
                      height: 45.0,
                      margin:
                          EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => rightButton(),
                        child: Image.asset('assets/noti_list.png',
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              : Container(
                  child: Container(
                    child: Container(
                      width: 24.0,
                      height: 24.0,
                      margin:
                          EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => rightButton(),
                        child: Image.asset('assets/logo/icons/Group344.png'),
                      ),
                    ),
                  ),
                )
          : Container(),
    ],
  );
}
