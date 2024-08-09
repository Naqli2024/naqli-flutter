import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

AppBar commonAppBar(BuildContext context,{PreferredSizeWidget? bottom}) {
  return AppBar(
          leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu,
                color: Color(0xff5D5151),
                size: 50,
              )),
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SvgPicture.asset('assets/naqlee-logo.svg',
                height: MediaQuery.of(context).size.height * 0.05),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Text(
                    'User',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Stack(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications,
                            color: Color(0xff6A66D1),
                            size: 30,
                          )),
                      Positioned(
                        right: 10,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          bottom: bottom
  );
}
