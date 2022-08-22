import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import 'app.dart';

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        AppColors.preferencesButtonColor,
      ),
    );
    const borderRadius = 15.0;
    const legalese = '© Dronetag s.r.o., 2022';
    final buildText = 'build ${packageInfo!.buildNumber}';
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            color: Color.fromARGB(200, 100, 100, 100),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: Sizes.mapContentMargin * 2,
        vertical: MediaQuery.of(context).size.height / 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF0084DC),
                    Color(0xFF455CD2),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Sizes.mapContentMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/images/icon_transparent.png',
                      width: MediaQuery.of(context).size.height / 12,
                    ),
                    const Text(
                      'Drone Scanner',
                      textScaleFactor: 1.6,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 3,
                      ),
                      child: Text(
                        packageInfo?.version ?? 'unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0084DC),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      child: Text(
                        buildText,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  Sizes.mapContentMargin,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: width / 2,
                      child: ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'Drone Scanner',
                            applicationVersion:
                                packageInfo?.version ?? 'unknown',
                            applicationIcon: Image.asset(
                              'assets/images/icon_transparent.png',
                              width: 48,
                              height: 64,
                            ),
                            applicationLegalese: legalese,
                          );
                        },
                        child: const Text('View 3rd-party licenses'),
                      ),
                    ),
                    SizedBox(
                      width: width / 2,
                      child: ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {},
                        child: const Text('Send diagnostics logs'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Developed by '),
                              Image.asset(
                                'assets/images/dronetag_logo.png',
                                width: width / 5,
                              ),
                            ],
                          ),
                          const Text(legalese),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
