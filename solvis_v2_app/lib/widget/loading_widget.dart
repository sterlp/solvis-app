import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: Image.asset('resources/solvis_v2_icon.png'),
              ),
              const SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(strokeWidth: 6.0),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Laden ...', style: Theme.of(context).textTheme.headline6))
        ],
      ),
    );
  }
}
