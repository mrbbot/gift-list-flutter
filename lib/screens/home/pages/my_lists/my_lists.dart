import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:gift_list/components/gift_list_card.dart';

class MyListsPage extends StatefulWidget {
  final List<GiftList> myLists;

  final RefreshCallback onRefresh;
  final ValueSetter<int> onClick;
  final AsyncValueSetter<int> onRemove;

  MyListsPage({
    this.myLists,
    this.onRefresh,
    this.onClick,
    this.onRemove,
  });

  @override
  _MyListsPageState createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  List<int> _working;

  @override
  void initState() {
    super.initState();
    _working = [];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: new ListView.builder(
        itemBuilder: (BuildContext context, int i) {
          return new Padding(
            padding: (i == widget.myLists.length - 1)
                ? const EdgeInsets.all(8.0)
                : const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: new GiftListCard(
              giftList: widget.myLists[i],
              working: _working.contains(widget.myLists[i].id),
              onClick: () => widget.onClick(widget.myLists[i].id),
              onRemove: () async {
                setState(() => _working.add(widget.myLists[i].id));
                await widget.onRemove(widget.myLists[i].id);
                setState(() => _working.remove(widget.myLists[i].id));
              },
            ),
          );
        },
        itemCount: widget.myLists.length,
      ),
    );
  }
}
