// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart.vmstats;

import 'dart:async';
import 'dart:html';
import 'dart:json' as JSON;

part 'bargraph.dart';
part 'isolate_list.dart';
part 'models.dart';

BarGraph _graph;
IsolateList _isolateList;
DivElement _statusText;
IsolateListModel _isolates;
Timer _updater;

final int _POLL_INTERVAL_IN_MS = 1000;

void main() {
  DivElement dashBoard = query('#dashboard');
  CanvasElement canvas = query('#graph');
  var elements = [ new Element("Old Space", "#97FFFF"),
                   new Element("New Space", "#00EE76")];
  _graph = new BarGraph(canvas, elements);
  UListElement isolateListElement = query('#isolateList');
  _isolateList = new IsolateList(isolateListElement);
  _statusText = query('#statusText');

  _isolates = new IsolateListModel();
  _isolates.addListener(onUpdateStatus, onRequestFailed);
  _isolates.update();
  _updater =
      new Timer.repeating(_POLL_INTERVAL_IN_MS, (timer) => _isolates.update());
}

void onUpdateStatus(IsolateListModel model) {
  int oldSpace = 0;
  int newSpace = 0;
  model.forEach((Isolate element) {
    oldSpace += element.oldSpace.used;
    newSpace += element.newSpace.used;
  });
  _graph.addSample([oldSpace, newSpace]);
  _isolateList.updateList(model);
  showStatus('Running ...');
}

void onRequestFailed() {
  _updater.cancel();
  _isolates.removeListener(onUpdateStatus);
  showStatus('Server closed');
}

void showStatus(status) {
  _statusText.text = status;
}
