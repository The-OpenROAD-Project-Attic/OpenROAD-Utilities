///////////////////////////////////////////////////////////////////////////////
// Authors: Mingyu Woo
//
// BSD 3-Clause License
//
// Copyright (c) 2019, The Regents of the University of California
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of the copyright holder nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
///////////////////////////////////////////////////////////////////////////////

#ifndef __GLOBAL_DEF_GENERATER__
#define __GLOBAL_DEF_GENERATER__ 0

#include <iostream>
#include <string>
#include <vector>
#include <climits>
#include <limits>
#include <cfloat>
#include <unordered_map>
#include <unordered_set>

using std::string;
using std::vector;
using std::cout;
using std::endl;
using std::to_string;
using std::unordered_map;
using std::unordered_set;
using std::pair;
using std::ofstream;
using std::ifstream;
using std::stringstream;
using std::make_pair; 
extern string verilogStr;


namespace DefGenerator {
class Pin {
  public:
  string name;
  double pinX, pinY; 
  string layerName; 
  Pin( string _name, double _pinX, double _pinY, 
      string _layerName) :
    name(_name), pinX(_pinX), pinY(_pinY), layerName(_layerName) {};
};
};


class EnvFile {
  public:
    vector<DefGenerator::Pin> pinStor;
    // pinName to pinStor's index
    unordered_map<string, int> pinNameMap;

    vector<std::string> lefStor;
    vector<std::string> libStor;
    string verilogStr;
    string defStr;
    string pinLocationStr;
    string pinLocationContStr;
    string design;
    string siteName;

    int defDbu;
    double dieAreaLx;
    double dieAreaLy;
    double dieAreaUx;
    double dieAreaUy;
     
    int layoutLx;
    int layoutLy;

    int siteSizeX;
    int siteSizeY;
    int rowCntX; 
    int rowCntY;

    EnvFile() : verilogStr(""), defStr(""), pinLocationStr(""),
      pinLocationContStr(""), 
      design(""), siteName(""), defDbu(INT_MIN), 
      dieAreaLx(DBL_MIN), dieAreaLy(DBL_MIN),
      dieAreaUx(DBL_MIN), dieAreaUy(DBL_MIN), 
      layoutLx(INT_MIN), layoutLy(INT_MIN),
      siteSizeX(INT_MIN), siteSizeY(INT_MIN), 
      rowCntX(INT_MIN), rowCntY(INT_MIN) {};

    bool IsFilled() {
      return verilogStr != "" && defStr != "" && design != "" && siteName != "" &&
        defDbu != INT_MIN && dieAreaLx != DBL_MIN && dieAreaLy != DBL_MIN &&
        dieAreaUx != DBL_MIN && dieAreaUy != DBL_MIN;
    } 
};

// for string escape
inline bool ReplaceStringInPlace( std::string& subject, 
        const std::string& search,
        const std::string& replace) {
    size_t pos = 0;
    bool isFound = false;
    while ((pos = subject.find(search, pos)) != std::string::npos) {
         subject.replace(pos, search.length(), replace);
         pos += replace.length();
         isFound = true; 
    }
    return isFound; 
}

inline void SetEscapedStr( std::string& inp ) {
    if( ReplaceStringInPlace(inp, "/", "\\/" ) ) {
        ReplaceStringInPlace(inp, "[", "\\[" );
        ReplaceStringInPlace(inp, "]", "\\]" );
    }
}

inline char* GetEscapedStr( const char* name ) {
    std::string tmp(name);
    SetEscapedStr(tmp);
    return strdup( tmp.c_str());
}

#endif
