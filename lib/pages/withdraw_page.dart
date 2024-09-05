import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WithdrawPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Withdraw Funds'),
      ),
      child: Center(
        child: Text('Withdraw Funds Page Content'),
      ),
    );
  }
}
