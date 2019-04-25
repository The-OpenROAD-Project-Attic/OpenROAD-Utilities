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
