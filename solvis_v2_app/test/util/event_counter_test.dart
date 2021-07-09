import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solvis_v2_app/main.dart';
import 'package:solvis_v2_app/util/event_counter.dart';

void main() {

  test('Counts error numbers', () {
    final subject = EventCounter<String>(33);
    expect(subject.eventCount, 0);

    subject.count('ja');
    expect(subject.eventCount, 1);

    subject.count('ja');
    expect(subject.eventCount, 2);

    subject.count('ja');
    expect(subject.eventCount, 3);
  });

  test('Counts one and has event', () {
    final subject = EventCounter<String>(2);

    subject.count('ja');
    expect(subject.isMaxReached, false);
    expect(subject.event, 'ja');
  });

  test('Max reached', () {
    final subject = EventCounter<String>(2);
    expect(subject.isMaxNotReached, true);

    subject.count('ja');
    expect(subject.isMaxNotReached, true);

    subject.count('nein');
    expect(subject.isMaxNotReached, true);

    subject.count('tot');
    expect(subject.isMaxReached, true);
    expect(subject.isMaxNotReached, false);
  });

  test('Has last event', () {
    final subject = EventCounter<String>(2);

    subject.count('ja');
    expect(subject.event, 'ja');

    subject.count('nein');
    expect(subject.event, 'nein');

    subject.count('tot');
    expect(subject.event, 'tot');
  });

  test('Can set to max reached', () {
    final subject = EventCounter<String>(99);
    expect(subject.isMaxNotReached, true);
    expect(subject.isMaxReached, false);

    subject.maxReached('Total kaputt');
    expect(subject.isMaxNotReached, false);
    expect(subject.isMaxReached, true);
    expect(subject.event, 'Total kaputt');
  });
}
