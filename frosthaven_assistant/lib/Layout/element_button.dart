
import 'package:flutter/material.dart';

import '../Resource/commands/imbue_element_command.dart';
import '../Resource/commands/use_element_command.dart';
import '../Resource/enums.dart';
import '../Resource/game_state.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';

class ElementButton extends StatefulWidget {
  final String icon;
  final Color color;
  final Elements element;
  final double width = 40;
  final double borderWidth = 2;

  const ElementButton(
      {Key? key,
      required this.icon,
      required this.color,
      required this.element})
      : super(key: key);

  @override
  AnimatedContainerButtonState createState() =>
      AnimatedContainerButtonState();
}

class AnimatedContainerButtonState extends State<ElementButton> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.
  final GameState _gameState = getIt<GameState>();
  final Settings settings = getIt<Settings>();
  late double _height;
  late Color _color;
  late BorderRadiusGeometry _borderRadius;

  @override
  void initState() {
    super.initState();
    _height = widget.width * settings.userScalingBars.value;
    _color = Colors.transparent;
    _borderRadius =
        BorderRadius.all(Radius.circular(widget.width * settings.userScalingBars.value - widget.borderWidth * settings.userScalingBars.value * 2));

    //to load save state
    _gameState.elementState.addListener(() {
      if (_gameState.elementState.value[widget.element] != null) {
        ElementState state = _gameState.elementState.value[widget.element]!;
        if (state == ElementState.full) {
          if(mounted) {
            setState(() {
              setFull();
            });
          }
        }
        else if (state == ElementState.half) {
          if(mounted) {
            setState(() {
              setHalf();
            });
          }
        }
      }
    });
  }

  void setHalf(){
    _color = widget.color;
    _height = widget.width * settings.userScalingBars.value / 2 +2 * settings.userScalingBars.value;
    _borderRadius = BorderRadius.only(
        bottomLeft:
        Radius.circular(widget.width * settings.userScalingBars.value / 2 - widget.borderWidth * settings.userScalingBars.value * 0),
        bottomRight:
        Radius.circular(widget.width * settings.userScalingBars.value / 2 - widget.borderWidth* settings.userScalingBars.value * 0));
  }

  void setFull(){
    _color = widget.color;
    _height = widget.width * settings.userScalingBars.value;
    _borderRadius = BorderRadius.all(
        Radius.circular(widget.width  * settings.userScalingBars.value - widget.borderWidth * settings.userScalingBars.value));
  }

  void setInert(){
    _color = Colors.transparent;
    _height =  4 * settings.userScalingBars.value;
    _borderRadius = BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //behavior: HitTestBehavior.opaque,


        onDoubleTap: () {
          setState(() {
            _gameState.elementState.value
                .update(widget.element, (value) => ElementState.half);
            _gameState.action(ImbueElementCommand(widget.element, true));
           // setHalf();
          });
        },
        onTapDown: (TapDownDetails details) {
          setState(() {
            if (_gameState.elementState.value[widget.element] !=
                ElementState.inert) {
              _gameState.elementState.value
                  .update(widget.element, (value) => ElementState.inert);
            } else {
              _gameState.elementState.value
                  .update(widget.element, (value) => ElementState.full);
            }
            if (_gameState.elementState.value[widget.element] ==
                ElementState.half) {
              _gameState.action(ImbueElementCommand(widget.element, true));

              //setHalf();
            } else if (_gameState.elementState.value[widget.element] ==
                ElementState.full) {
              _gameState.action(ImbueElementCommand(widget.element, false));

            } else {
              _gameState.action(UseElementCommand(widget.element));
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right:2 * settings.userScalingBars.value ),
              padding: EdgeInsets.only(bottom: 2 * settings.userScalingBars.value),
                child: Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<int>(
                  valueListenable: _gameState.commandIndex,
                  builder: (context, value, child) {
                    if (_gameState.elementState.value[widget.element] == ElementState.inert) {
                      setInert();
                    }
                    else if (_gameState.elementState.value[widget.element] == ElementState.half) {
                      setHalf();
                    }
                    else if (_gameState.elementState.value[widget.element] == ElementState.full) {
                      setFull();
                    }

                    return AnimatedContainer(
                      // Use the properties stored in the State class.
                      width: widget.width * settings.userScalingBars.value - widget.borderWidth * settings.userScalingBars.value * 2,
                      height: _height - widget.borderWidth * settings.userScalingBars.value * 2,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: _color,
                          borderRadius: _borderRadius,
                          boxShadow: [
                            _gameState.elementState.value[widget.element] !=
                                    ElementState.inert
                                ? BoxShadow(
                              //blurStyle: BlurStyle.solid,
                                    //spreadRadius: 2 * settings.userScalingBars.value,
                                    blurRadius: 4 * settings.userScalingBars.value)
                                : const BoxShadow(
                                    color: Colors.transparent,
                                  )
                          ]),
                      // Define how long the animation should take.
                      duration: const Duration(milliseconds: 600),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.decelerate//Curves.linearToEaseOut
                    );
                  }),
            )),
            Image(
              //fit: BoxFit.contain,
              height: widget.width * settings.userScalingBars.value * 0.75,
              image: AssetImage(widget.icon),
              width: widget.width * settings.userScalingBars.value * 0.75,

            ),
          ],
        ));
  }
}
