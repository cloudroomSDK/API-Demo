import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'application/application.dart';
import '/component/common_func.dart';

import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';

class AudioConfig extends StatefulWidget {
  const AudioConfig({Key? key}) : super(key: key);

  @override
  _AudioConfigState createState() => _AudioConfigState();
}

class _AudioConfigState extends State<AudioConfig> with CommonFunc {
  int? confId = GlobalConfig.instance.confID;
  String nickName = GlobalConfig.instance.nickName;
  double _volume = 0;

  @override
  void initState() {
    super.initState();
  }

  getMicVolume() {
    CrSDK.instance.getMicVolume().then((volume) => setState(() {
          _volume = volume.toDouble();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("房间号：$confId"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              exitMeeting();
            },
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            return await exitMeeting();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xff1D232F),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                      child: Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(76.5),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("assets/images/voiceprint.png"),
                      fit: BoxFit.cover,
                    )),
                  )),
                ),
                Container(
                  width: double.infinity,
                  height: ScreenUtil().setHeight(156.5),
                  color: Colors.black,
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(35.5),
                      right: ScreenUtil().setWidth(35.5),
                      top: ScreenUtil().setHeight(30)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("选择采集音量",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(14))),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(10)),
                          child: Row(
                            children: [
                              Expanded(
                                  child: SliderTheme(
                                      data: const SliderThemeData(
                                        trackHeight: 2.0,
                                        // trackShape: CustomTrackShape()
                                      ),
                                      child: Slider(
                                        value: _volume,
                                        min: 0,
                                        max: 255,
                                        divisions: 255,
                                        label: _volume.round().toString(),
                                        inactiveColor: const Color(0xffB1B1B1),
                                        onChanged: (double value) {
                                          setState(() {
                                            _volume = value;
                                          });
                                        },
                                      ))),
                              SizedBox(
                                width: ScreenUtil().setWidth(40),
                                child: Text(
                                  _volume.round().toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(14)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setHeight(5)),
                          child: Center(
                            child: SizedBox(
                              width: ScreenUtil().setWidth(100),
                              height: ScreenUtil().setHeight(30),
                              child: ElevatedButton(
                                  child: const Text("退出"),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xfff44e4e)),
                                    textStyle: MaterialStateProperty.all(
                                        TextStyle(
                                            fontSize: ScreenUtil().setSp(14))),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0))),
                                  ),
                                  onPressed: () {
                                    exitMeeting();
                                  }),
                            ),
                          ),
                        )
                      ]),
                )
              ],
            ),
          ),
        ));
  }
}
