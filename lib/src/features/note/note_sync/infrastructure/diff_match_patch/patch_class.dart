/*
 * Diff Match and Patch
 * Copyright 2018 The diff-match-patch Authors.
 * https://github.com/google/diff-match-patch
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of diff_match_patch;

/// Class representing one patch operation.
class Patch {
  List<Diff> diffs = List.empty(growable: true);
  int start1 = 0;
  int start2 = 0;
  int length1 = 0;
  int length2 = 0;

  /// Constructor.  Initializes with an empty list of diffs.
  Patch();

  /// Emulate GNU diff's format.
  /// Header: @@ -382,8 +481,9 @@
  /// Indices are printed as 1-based, not 0-based.
  /// Returns the GNU diff string.
  @override
  String toString() {
    String coords1, coords2;
    if (length1 == 0) {
      coords1 = '$start1,0';
    } else if (length1 == 1) {
      coords1 = (start1 + 1).toString();
    } else {
      coords1 = '${start1 + 1},$length1';
    }
    if (length2 == 0) {
      coords2 = '$start2,0';
    } else if (length2 == 1) {
      coords2 = (start2 + 1).toString();
    } else {
      coords2 = '${start2 + 1},$length2';
    }
    final text = StringBuffer('@@ -$coords1 +$coords2 @@\n');
    // Escape the body of the patch with %xx notation.
    for (Diff aDiff in diffs) {
      switch (aDiff.operation) {
        case Operation.insert:
          text.write('+');
          break;
        case Operation.delete:
          text.write('-');
          break;
        case Operation.equal:
          text.write(' ');
          break;
      }
      text.write(Uri.encodeFull(aDiff.text));
      text.write('\n');
    }
    return text.toString().replaceAll('%20', ' ');
  }
}
