import 'package:flutter/material.dart';

class KaalShape {
  // Border radii — from tokens.json radii_used (frequency ordered)
  static const BorderRadius card        = BorderRadius.all(Radius.circular(12)); // default card
  static const BorderRadius statCard    = BorderRadius.all(Radius.circular(14)); // .sc
  static const BorderRadius switchTrack = BorderRadius.all(Radius.circular(9));  // .sw
  static const BorderRadius sgrpIcon    = BorderRadius.all(Radius.circular(8));  // .sgrp-ico
  static const BorderRadius setIco      = BorderRadius.all(Radius.circular(6));  // .set-ico
  static const BorderRadius pill        = BorderRadius.all(Radius.circular(3));  // .pill
  static const BorderRadius bottomNav   = BorderRadius.all(Radius.circular(16)); // .bnav
  static const BorderRadius altCard     = BorderRadius.all(Radius.circular(10)); // alt card
  static const BorderRadius filterChip  = BorderRadius.all(Radius.circular(6));  // filter chips
  static const BorderRadius tag         = BorderRadius.all(Radius.circular(5));  // inline tag
  static const BorderRadius input       = BorderRadius.all(Radius.circular(4));  // text inputs
  static const BorderRadius roundChip   = BorderRadius.all(Radius.circular(18)); // round chip

  const KaalShape();
}
