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

#include <iostream>
#include <fstream>
#include <sstream>
#include <streambuf>
#include <unordered_set>
#include "lefdefIO.h"
#include "global.h"
#include "timingSta.h"
#include "defrData.hpp"

#define compileDate __DATE__
#define compileTime __TIME__

using namespace sta;

bool argument(int argc, char *argv[], EnvFile& env);
void PrintHelp();
void ParsePinLocation(EnvFile& env);

// store multi-pin nets. 
// this happenes when multi pin exists on a single net
// This will change PINS and NETS section on def. 
struct MultiPinNet { 
  string netName;
  vector<Pin*> pinStor;

  void Dump(sta::Sta* sta, int i) {
    cout << "i: " << i << endl;
    cout << "netName: " << netName << endl;
    for(auto& curPin: pinStor) {
      cout << "pins: " << sta->network()->pathName(curPin) << endl;
    }
    cout << endl;
  }
};

struct MultiPinNetInfo {
  vector<MultiPinNet> multiPinNets;

  // Pin* --> multiPinNets's index map
  unordered_map<Pin*, size_t> multiPinMap;

  void Dump(sta::Sta* sta) {
    for(auto& curMpinNet: multiPinNets) {
      curMpinNet.Dump(sta, &curMpinNet - &multiPinNets[0]);
    }
  }
};
  
void FillRow(Circuit::Circuit& ckt, EnvFile &env);
void FillComponent(sta::Sta* sta, Circuit::Circuit& ckt);
void FillComponentPrivate( sta::Sta* sta, 
    Circuit::Circuit& ckt, 
    defrData& defData, Instance* inst ); 

void FillMultiPinNetInfo ( sta::Sta* sta, 
    Circuit::Circuit& ckt,
    MultiPinNetInfo &multiPinNetInfo );
void FillPins(sta::Sta* sta, Circuit::Circuit& ckt, EnvFile &env,
    const MultiPinNetInfo& multiPinNetInfo);

void FillNets(sta::Sta* sta, Circuit::Circuit& ckt,
    const MultiPinNetInfo& multiPinNetInfo);

void FillNetPrivate( sta::Sta* sta, 
    Circuit::Circuit& ckt, 
    defiNet& curNet, Net* net, int& subNetCnt,
    unordered_set<Net*>& vddSet, 
    unordered_set<Net*>& vssSet, 
    const MultiPinNetInfo& multiPinNetInfo,
    vector<int>& isVisitPin);

void FillInstNets( sta::Sta* sta, 
    Circuit::Circuit& ckt, 
    Instance* inst, defrData& defData,
    unordered_set<Net*>& vddSet, 
    unordered_set<Net*>& vssSet,
    const MultiPinNetInfo& multiPinNetInfo, 
    vector<int>& isVisitPin);

void FillVddVssNet( sta::Sta* sta,
    Circuit::Circuit& ckt,
    defrData& defData, 
    unordered_set<Net*>& vddSet,
    unordered_set<Net*>& vssSet);


int main(int argc, char *argv[]) {

  EnvFile env;
  if( !argument(argc, argv, env) ) {
    PrintHelp();
    cout << "input param error!! " << endl;
    exit(1);
  }

  Circuit::Circuit ckt;
  ckt.Init( env.lefStor );

  cout << "LEF Parsing Done" << endl;

  if( env.pinLocationStr != "" ) { 
    ParsePinLocation( env );
    cout << "Pin Location Parsing Done" << endl;
  }
 
  defrData defData(NULL, NULL, NULL); 

  ckt.defVersion = "5.8";
  ckt.defDividerChar = "/";
  ckt.defBusBitChar = "[]";
  ckt.defDesignName = env.design;

  // def DBU settings
  ckt.defUnit = env.defDbu;
  cout << "DEF DBU: " << env.defDbu << endl;

  auto sitePtr = ckt.lefSiteMap.find(env.siteName);
  if( sitePtr == ckt.lefSiteMap.end()) {
    cout << "** ERROR: Cannot Find Site in LEF: " << env.siteName << endl;
    exit(1);
  }
  if( !ckt.lefSiteStor[sitePtr->second].hasSize() ) {
    cout << "** ERROR: Site in LEF: " << env.siteName << " doesn't have Size! " << endl;
    exit(1);
  }

  double siteSizeX = ckt.lefSiteStor[sitePtr->second].sizeX();
  double siteSizeY = ckt.lefSiteStor[sitePtr->second].sizeY();
  cout << "Site Found: " << env.siteName << " ";
  cout << siteSizeX*env.defDbu << " " << siteSizeY*env.defDbu << endl;

  
  // dieArea Settings
  double width = env.dieAreaUx - env.dieAreaLx;
  double height = env.dieAreaUy - env.dieAreaLy;
  int siteCntX = int( 1.0*width/siteSizeX + 0.5f );
  int siteCntY = int( 1.0*height/siteSizeY + 0.5f );

  env.dieAreaUx = env.dieAreaLx + siteCntX*siteSizeX;
  env.dieAreaUy = env.dieAreaLy + siteCntY*siteSizeY;

  cout << "Trimmed New DieArea: " << env.dieAreaLx << " " << env.dieAreaLy 
    << " " << env.dieAreaUx << " " << env.dieAreaUy  << endl;
 
  defiGeometries geom(&defData);

  geom.startList( (int)(env.dieAreaLx*env.defDbu+0.5f), (int)(env.dieAreaLy*env.defDbu+0.5f) );
  geom.addToList( (int)(env.dieAreaUx*env.defDbu+0.5f), (int)(env.dieAreaUy*env.defDbu+0.5f) );

  ckt.defDieArea.addPoint(&geom); 

 
//  EnvFile env;
//  env.verilog = verilogStr;
//  env.libStor = libStor;
//  env.pinLocationStr = pinLocationStr;
//  env.design = design;
//  env.siteName = siteName;
  
  env.layoutLx = env.dieAreaLx*env.defDbu;
  env.layoutLy = env.dieAreaLy*env.defDbu;
  env.siteSizeX = siteSizeX*env.defDbu;
  env.siteSizeY = siteSizeY*env.defDbu;
  env.rowCntX = (env.dieAreaUx - env.dieAreaLx)/siteSizeX;
  env.rowCntY = (env.dieAreaUy - env.dieAreaLy)/siteSizeY;
  cout << env.rowCntX << " " << env.rowCntY << endl;


  cout << "Executing OpenSTA to parse Verilog...." << endl;

  sta::Sta* sta = GetStaObject( env );
  cout << "Verilog Parsing done" << endl;

  FillRow(ckt, env);
  FillComponent(sta, ckt);

  // Get Information about multiPinStor;
  MultiPinNetInfo multiPinNetInfo;
  FillMultiPinNetInfo(sta, ckt, multiPinNetInfo );
  multiPinNetInfo.Dump(sta);
  
//  exit(1);

  // Fill Pins
  FillPins(sta, ckt, env, multiPinNetInfo);
  FillNets(sta, ckt, multiPinNetInfo);

  cout << "DEF Writing into " << env.defStr << "..." << endl; 
  FILE* defFile = fopen( env.defStr.c_str(), "w");
  ckt.WriteDef( defFile, true );
  cout << "DEF Generated!" << endl; 

   
  // defiPoints points = ckt.defDieArea.getPoint();
  // cout << points.numPoints << endl;
  // for(int i=0; i<points.numPoints; i++ ) {
  //   cout << 1.0*points.x[i]/defScale << " " 
  //   << 1.0*points.y[i]/defScale << endl;
  // }
  // cout << ckt.defDieArea.xl() << " " << ckt.defDieArea.yl() << " "
  //   << ckt.defDieArea.xh() << " " << ckt.defDieArea.yh() << endl;


  // for BLK
//  WriteDef(&ckt, defStr);

  return 0;
}

void PrintHelp() {
  cout << "./defgenerater -lef <lef1> -lef <lef2> -lib <lib1> -lib <lib2> -verilog <verilog> -def <def> -defDbu <dbu:int> -dieAreaInMicron <lx:double> <ly:double> <ux:double> <uy:double> -siteName <siteName:string> -design <designName> -pinLocation <*.pins> " << endl;
}

bool argument(int argc, char *argv[], EnvFile& env) {
  if( argc <= 1 ) {
    return false;
  }

//  defStr = verilogStr = siteName = pinLocationStr = "";
//  defDbu = INT_MIN;
//  dieAreaLx = dieAreaLy = dieAreaUx = dieAreaUy = DBL_MIN;


  for(int i = 1; i < argc; i++) {
    if(!strcmp(argv[i], "-lef")) {
      i++;
      if(argv[i][0] != '-') {
        env.lefStor.push_back( string(argv[i]) );
      }
      else {
        printf("\n**ERROR: Option %s requires *.lef.\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-def")) {
      i++;
      if(argv[i][0] != '-') {
        env.defStr = argv[i];
      }
      else {
        printf("\n**ERROR: Option %s requires *.def.\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-verilog")) {
      i++;
      if(argv[i][0] != '-') {
        env.verilogStr = argv[i];
      }
      else {
        printf("\n**ERROR: Option %s requires *.v\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-lib")) {
      i++;
      if(argv[i][0] != '-') {
        env.libStor.push_back( string(argv[i]) );
      }
      else {
        printf("\n**ERROR: Option %s requires *.lib\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-siteName")) {
      i++;
      if(argv[i][0] != '-') {
        env.siteName = argv[i];
      }
      else {
        printf("\n**ERROR: Option %s requires siteName.\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-defDbu")) {
      i++;
      if(argv[i][0] != '-') {
        env.defDbu = atof(argv[i]);
      }
      else {
        printf("\n**ERROR: Option %s requires defDbu.\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-design")) {
      i++;
      if(argv[i][0] != '-') {
        env.design = argv[i];
      }
      else {
        printf("\n**ERROR: Option %s requires designName.\n",
            argv[i - 1]);
        return false;
      }
    }
    // Note that pinLocation is optional
    else if(!strcmp(argv[i], "-pinLocation")) {
      i++;
      if(argv[i][0] != '-') {
        env.pinLocationStr = argv[i];
      }
      else {
        printf("\n**ERROR: Option %s requires pinLocationFile.\n",
            argv[i - 1]);
        return false;
      }
    }
    else if(!strcmp(argv[i], "-dieAreaInMicron")) {
      i++;
      if(argv[i][0] != '-') {
        env.dieAreaLx = atof(argv[i]);
      }
      else {
        printf("\n**ERROR: Option %s requires dieAreaLx.\n",
            argv[i - 1]);
        return false;
      }
      i++;
      if(argv[i][0] != '-') {
        env.dieAreaLy = atof(argv[i]);
      }
      else {
        printf("\n**ERROR: Option %s requires dieAreaLy.\n",
            argv[i - 1]);
        return false;
      }
      i++;
      if(argv[i][0] != '-') {
        env.dieAreaUx = atof(argv[i]);
      }
      else {
        printf("\n**ERROR: Option %s requires dieAreaUx.\n",
            argv[i - 1]);
        return false;
      }
      i++;
      if(argv[i][0] != '-') {
        env.dieAreaUy = atof(argv[i]);
      }
      else {
        printf("\n**ERROR: Option %s requires dieAreaUy.\n",
            argv[i - 1]);
        return false;
      }
    }
  }
  cout << "argc and argv list: " << endl;
  for(int i=0; i<argc; i++) {
    cout << i << " " << argv[i] << endl;
  }
  
  return env.IsFilled();
}

void ParsePinLocation(EnvFile& env) {
  ifstream pinFile;
  pinFile.open( env.pinLocationStr);
  if( !pinFile.good() ) {
    cout << "**ERROR: Cannot Open the " << env.pinLocationStr << endl;
    exit(1);
  }

  /*
   * previous DEF copy function 
  
  stringstream buffer;
  buffer << pinFile.rdbuf();
  env.pinLocationContStr = buffer.str();
  */

  string line;
  while( getline (pinFile, line) ) {
    // split by empty space
    std::istringstream iss(line);
    std::vector<std::string> results(std::istream_iterator<std::string>{iss},
      std::istream_iterator<std::string>());
   
    string name = "";
    double pinX = 0.0f, pinY = 0.0f; 
    string layerName = "";
    char pinOrient = '\0';

    if( results.size() > 4) { 
      cout << "ERROR: " << env.pinLocationStr 
        << " must have four elements in one line " << endl;
      exit(1); 
    }

    for(auto& curStr: results ) {
      int idx = &curStr - &results[0];
      if( idx == 0 ) {
        name = curStr;
      }
      else if( idx == 1 ) {
        pinX = atof( curStr.c_str() );
      }
      else if( idx == 2 ) {
        pinY = atof( curStr.c_str() );
      }
      else if( idx == 3 ) {
        layerName = curStr;
      }
    }
    auto pnPtr = env.pinNameMap.find(name);
    if( pnPtr != env.pinNameMap.end()) {
      cout << "**ERROR: " << name << " exist twice in " << env.pinLocationStr << endl;
      exit(1);
    }
    env.pinNameMap[ name ] = env.pinStor.size();
    env.pinStor.push_back( DefGenerator::Pin( name, pinX, pinY, layerName ) );
//    cout << "name: " << name << ", xy = " << pinX << ", " << pinY << endl; 
  }
  pinFile.close(); 
}

// Rows Settings
void FillRow(Circuit::Circuit& ckt, EnvFile &env) {
  defrData defData(NULL, NULL, NULL);
 
  int y = 0;
  for(int i=0; i<env.rowCntY; i++) {
    defiRow curRow(&defData); 
    curRow.setup(string("ROW_"+to_string(i)).c_str(), env.siteName.c_str(), 
        env.layoutLx, y, (i%2==0)? 6:0);
    curRow.setHasDoStep();
    curRow.setDo(env.rowCntX, 1, env.siteSizeX, 0); 

    y += env.siteSizeY;
    ckt.defRowStor.push_back(curRow);
  } 
}


// Component Settings
void FillComponent(sta::Sta* sta, Circuit::Circuit& ckt) {
  
  sta::Network* network = sta->networkReader();
  int compCnt = network->instanceCount();
  defrData defData(NULL, NULL, NULL);
//  InstanceChildIterator* instIter = network->childIterator(network->topInstance());

  FillComponentPrivate(sta, ckt, defData, network->topInstance() );

//  while(instIter->hasNext()) {
//    Instance* inst = instIter->next();
//    defiComponent curComp(&defData);
//    string compName = network->pathName(inst);
//    ReplaceStringInPlace( compName, "\\[", "[");
//    ReplaceStringInPlace( compName, "\\]", "]");
//    ReplaceStringInPlace( compName, "\\/", "/");

//    cout << inst << " " << compName << endl;
//    InstanceChildIterator* innerInstIter = network->childIterator(inst);
//    while( innerInstIter->hasNext() ){
//      Instance* innerInst = innerInstIter->next();
//      cout << "inner: " << network->pathName(innerInst) << endl;
//    }
//    cout << network->libertyCell(inst) << endl;
//    cout << network->libertyCell(inst)->name() << endl;
//    cout << compName << endl << endl;

//    curComp.IdAndName( compName.c_str(), network->libertyCell(inst)->name() );
//    curComp.setPlacementStatus(DEFI_COMPONENT_UNPLACED );
//    curComp.setPlacementLocation(-1, -1);
//    cout << network->libertyCell(inst)->name() << endl;
//    cout << network->pathName(inst) << endl;
//    ckt.defComponentStor.push_back( curComp );
//  }
  cout << "Fill Component Successful!" << endl; 
}

// Recursively traverse all of networks
void FillComponentPrivate( sta::Sta* sta, 
    Circuit::Circuit& ckt, 
    defrData& defData, Instance* inst ) {
 
  sta::Network* network = sta->networkReader();
  InstanceChildIterator* instIter = network->childIterator(inst);
  bool isHierarchical = false;
  while(instIter->hasNext()) {
    isHierarchical = true;
    Instance* inst = instIter->next();

    FillComponentPrivate( sta, ckt, defData, inst ); 
  }
//    InstanceChildIterator* innerInstIter = network->childIterator(inst);
//    if( innerInstIter -> hasNext() ) {
//      cout << network->libertyCell(inst) << endl;
//      cout << network->libertyCell(inst)->name() << endl;
//      cout << compName << endl << endl;

//    }
//    else {
  if( !isHierarchical ) {
      string compName = network->pathName(inst);
//      ReplaceStringInPlace( compName, "\\[", "[");
//      ReplaceStringInPlace( compName, "\\]", "]");
//      ReplaceStringInPlace( compName, "\\/", "/");
    
      defiComponent curComp(&defData);
//      cout << "inst: " << inst << " " << compName << endl;
//      cout << network->libertyCell(inst) << endl;
      if( !network->libertyCell(inst) ) {
        return;
      }
//      cout << network->libertyCell(inst)->name() << endl << endl;
      
      curComp.IdAndName( compName.c_str(), network->libertyCell(inst)->name() );
      curComp.setPlacementStatus(DEFI_COMPONENT_UNPLACED );
      curComp.setPlacementLocation(-1, -1);
      //    cout << network->libertyCell(inst)->name() << endl;
      //    cout << network->pathName(inst) << endl;
      ckt.defComponentStor.push_back( curComp );
  }
//    }
//  }
}

int GetOrient( int lx, int ly, int ux, int uy, int x, int y) {
  if( y == ly ) {
    return 0; // South 
  }
  else if( y == uy ) {
    return 2; // North
  }
  else if( x == lx ) {
    return 3; // East
  }
  else if( x == ux ) { 
    return 1; // West
  }
  else {
    return -1;
  }
}

string GetSecondLayerName(Circuit::Circuit& ckt) {
  int cnt = 0, layerIdx = INT_MAX;
  for(int i=0; i<ckt.lefLayerStor.size(); i++) {
    if( !ckt.lefLayerStor[i].hasWidth() ||
     !strcmp(ckt.lefLayerStor[i].name(), "ROUTING") ) {
      continue;
    }
    if( ++cnt == 2 ) {
      return ckt.lefLayerStor[i].name();
    }
  }
  cout << "ERROR: Cannot find metal2 Layer to Fill in DEF" << endl;
  exit(1);
}

// Pins Settings
void FillPins(sta::Sta* sta, Circuit::Circuit& ckt, EnvFile &env,
    const MultiPinNetInfo& multiPinNetInfo) {
//  if( env.pinLocationStr == "") {
//    return ; 
//  }

  defrData defData(NULL, NULL, NULL);
  sta::Network* network = sta->networkReader();
  VertexIterator vIter(sta->graph());

  int dieLx = int( env.dieAreaLx * env.defDbu + 0.5f );
  int dieLy = int( env.dieAreaLy * env.defDbu + 0.5f );
  int dieUx = int( env.dieAreaUx * env.defDbu + 0.5f );
  int dieUy = int( env.dieAreaUy * env.defDbu + 0.5f );

  string secLayerName = GetSecondLayerName(ckt);

  while(vIter.hasNext()) {
    Vertex* vertex = vIter.next();
    Pin* pin = vertex->pin();
    if( !network->isTopLevelPort(pin)) {
      continue;
    }
    PortDirection* dir = network->direction(pin);

    defiPin curPin(&defData);
    // multiPin Handling
    auto mpMap = multiPinNetInfo.multiPinMap.find( pin );
    
    if( mpMap != multiPinNetInfo.multiPinMap.end() ) {
      curPin.Setup( network->portName(pin), multiPinNetInfo.multiPinNets[ mpMap->second ].netName.c_str() );
    }
    else {
      curPin.Setup( network->portName(pin), network->portName(pin) );
    }

    string dirStr = (dir->isAnyOutput())? "OUTPUT" : "INPUT"; 
    curPin.setDirection( dirStr.c_str() );
    curPin.setUse( "SIGNAL" );

    auto pMapPtr = env.pinNameMap.find( string(network->portName(pin)) );
//    cout << network->portName(pin) << endl;
    DefGenerator::Pin* curGeneratorPin = NULL;
    bool isEmptyPin = false;
    if( pMapPtr == env.pinNameMap.end()) {
      cout << "WARNING: " << network->portName(pin) 
        << " not exists in *.pin. Will be placed on (0, 0, 2)" << endl;

      curGeneratorPin = 
        new DefGenerator::Pin( 
            string(network->portName(pin)), 0.0f, 0.0f, secLayerName) ;
      isEmptyPin = true;
    }
    else {
      curGeneratorPin = &env.pinStor[ pMapPtr->second ];
    }
    
    int curX = int(curGeneratorPin->pinX * env.defDbu+0.5f);
    int curY = int(curGeneratorPin->pinY * env.defDbu+0.5f);
    int orient = GetOrient(dieLx, dieLy, dieUx, dieUy, curX, curY);
    if( orient == -1 ) {
      cout << "ERROR: " << network->portName(pin) 
        << "'s pin location must be lied on layout edge" << endl;
      exit(1);
    }
    curPin.setPlacement(DEFI_COMPONENT_FIXED, curX, curY, 
        orient);

    auto lPtr = ckt.lefLayerMap.find( curGeneratorPin->layerName ); 
    if( lPtr == ckt.lefLayerMap.end() ) {
      cout << "ERROR: " << network->portName(pin) 
        << " pin's layer information not exists in LEF " 
        << curGeneratorPin->layerName << endl;
      exit(1);
    }
    lefiLayer *curLayer = &ckt.lefLayerStor[lPtr->second];
    if( !curLayer->hasWidth() ) {
      cout << "ERROR: " << curGeneratorPin->layerName 
        << " don't have WIDTH definition in LEF " << endl;
      exit(1);
    }
//    if( !curLayer->hasArea() ) {
//      cout << "ERROR: " << curGeneratorPin->layerName 
//        << " don't have minimum area definition (AREA) in LEF " << endl;
//      exit(1);
//    }
    int halfWidth = int( ceil((curLayer->width() * env.defDbu)/2.0) + 0.5f);
    int height = (curLayer->hasArea())? 
      int( ceil((curLayer->area() * env.defDbu * env.defDbu)/(2.0*halfWidth)) + 0.5f) :
      2 * halfWidth; 
//    cout << curLayer->width() << endl;
//    cout << curLayer->area() << endl;

//    cout << halfWidth << " " << height << endl;
//    cout << (curLayer->area() * env.defDbu * env.defDbu)/(2.0*halfWidth) << endl;
    curPin.addLayer( curGeneratorPin->layerName.c_str() );
    curPin.addLayerPts( -1*halfWidth, 0, halfWidth, height );
    ckt.defPinStor.push_back( curPin );
    if( isEmptyPin ) {
      delete curGeneratorPin; 
    }
  } 
  cout << "Fill Pin Successful!" << endl; 
}


// Nets Settings
void FillNets(sta::Sta* sta, Circuit::Circuit& ckt,
    const MultiPinNetInfo& multiPinNetInfo) {
  defrData defData(NULL, NULL, NULL);
  
  sta::Network* network = sta->networkReader();

  Instance* topInst = network->topInstance();

  unordered_set<Net*> vddSet;
  unordered_set<Net*> vssSet;

  int numVertex = sta->graph()->vertexCount();
  vector<int> isVisitPin(numVertex+1, 0);

  FillInstNets( sta, ckt, topInst, defData, vddSet, vssSet, multiPinNetInfo, isVisitPin );
  FillVddVssNet( sta, ckt, defData, vddSet, vssSet );

  unordered_set<string> netNameSet;
  for(auto& curNet: ckt.defNetStor) {
    netNameSet.insert( curNet.name() );
  }
  
  VertexIterator vIter(sta->graph());
  while(vIter.hasNext()) {
    Vertex* vertex = vIter.next();
    Pin* pin = vertex->pin();
    if( !network->isTopLevelPort(pin)) {
      continue;
    }

    // already pushed
    if( netNameSet.find( network->portName(pin))!= netNameSet.end() ) {
      continue;
    }
    // already considred in multiPinNets
    if( multiPinNetInfo.multiPinMap.find(pin) !=
        multiPinNetInfo.multiPinMap.end() ) {
      continue;
    }

    defiNet curNet(&defData);
    curNet.setName( network->portName(pin) );
    curNet.addPin( "PIN", network->portName(pin), 0);
    ckt.defNetStor.push_back(curNet);
  }
  

//  NetSeq* nets = new NetSeq;
  
//  string patternStr = "*";
//  PatternMatch pattern(patternStr.c_str());
//  network->findNetsHierMatching(topInst, &pattern, nets);
//  NetSeq::Iterator netsIter(nets);


  cout << "Fill Net Successful!" << endl; 

}

void FillInstNets( sta::Sta* sta, 
    Circuit::Circuit& ckt, 
    Instance* inst, 
    defrData& defData,
    unordered_set<Net*>& vddSet,
    unordered_set<Net*>& vssSet,
    const MultiPinNetInfo& multiPinNetInfo,
    vector<int>& isVisitPin) {

  sta::Network* network = sta->networkReader();
  InstanceNetIterator *netsIter = network->netIterator(inst);
  

  while(netsIter->hasNext()) {
    Net* net = netsIter->next();
   
//    cout << network->pathName(net) << " net visited " << net << endl; 
    // skip for subnet
    if( inst && inst != network->topInstance() ) {
      Pin* samePin = network->findPin( network->pathName(net));
      if( samePin ) {
//        cout << network->pathName(net) << " has samePin: " << network->pathName(samePin) << endl;
        continue;
      }
    }

    // VDD net consideration
    if( network->isPower(net) ){
      vddSet.insert(net);
      continue;
    }
    // VSS net consideration
    if( network->isGround(net) ) {
      vssSet.insert(net);
      continue;
    }
    
    defiNet curNet(&defData);
    
    // Set Net Name
    // check whether exists multiPinNets
    int multiPinIdx = INT_MAX;
    NetConnectedPinIterator* topPinIterator = network->connectedPinIterator(net);
    while( topPinIterator->hasNext() ) {
      Pin* curPin = topPinIterator->next();
     
      if( !network->isTopLevelPort(curPin) ) {
        continue;
      }

      auto mpPtr = multiPinNetInfo.multiPinMap.find(curPin);
      if( mpPtr != multiPinNetInfo.multiPinMap.end() ) {
        multiPinIdx = mpPtr->second;
        break;
      }
    }

    string netName = (multiPinIdx != INT_MAX)? 
      multiPinNetInfo.multiPinNets.at(multiPinIdx).netName : network->pathName(net);
//    ReplaceStringInPlace( netName, "\\[", "[");
//    ReplaceStringInPlace( netName, "\\]", "]");
//    ReplaceStringInPlace( netName, "\\/", "/");

    curNet.setName(netName.c_str());

    // DEF's NET can have below two subnets;
    // 1) ( PIN XXX ) // top-level-port case
    // 2) ( inst o ) // inst pin case
    //
    // pinNetCnt is for 1), subNetCnt is for 2)
    //
 
    int pinNetCnt = 0; 
    topPinIterator = network->connectedPinIterator(net);
    while( topPinIterator->hasNext() ) {
      Pin* curPin = topPinIterator->next();
     
      if( !network->isTopLevelPort(curPin) ) {
        continue;
      }
      const ConcretePin* cpin = reinterpret_cast<const ConcretePin*>(curPin);
//      cout << " pIdx: " << cpin->vertexIndex() << " inserted!" << endl;
      
      if( isVisitPin[ cpin->vertexIndex() ] == 1 ) {
        continue;
      }
      isVisitPin[ cpin->vertexIndex() ] = 1;
      curNet.addPin( "PIN", network->name(curPin), 0);
      pinNetCnt++;
    }

    int subNetCnt = 0;
    FillNetPrivate( sta, ckt, curNet, net, subNetCnt, vddSet, vssSet,
        multiPinNetInfo, isVisitPin);
    if( pinNetCnt >= 1 || subNetCnt >= 1) {
      ckt.defNetStor.push_back( curNet);
    }
    else {
//      cout << network->pathName(net) << " net has no Child" << endl; 
    } 
  } 
 
  // recursively call FillInstNets to traverse all child instances. 
  InstanceChildIterator* instIter = network->childIterator(inst);
  while(instIter->hasNext()) {
    Instance* inst = instIter->next();
    FillInstNets( sta, ckt, inst, defData, vddSet, vssSet, multiPinNetInfo, isVisitPin); 
  }
}



// Recursively traverse all of networks
void FillNetPrivate( sta::Sta* sta, 
    Circuit::Circuit& ckt, 
    defiNet& curNet, Net* net, int& subNetCnt,
    unordered_set<Net*>& vddSet, 
    unordered_set<Net*>& vssSet,
    const MultiPinNetInfo& multiPinNetInfo,
    vector<int>& isVisitPin) {
  sta::Network* network = sta->networkReader();
  NetPinIterator* pinIterator = network->pinIterator(net);

//  cout << "NetPrivate: netSearch: " << network->name(net) << endl;

  unordered_set<Pin*> pinMap;

  while( pinIterator->hasNext()) {
    Pin* curPin = pinIterator->next();
    Instance* curInst = network->instance(curPin);

    InstanceChildIterator* instIter = network->childIterator(curInst);
    Net* net = network->net(curPin);
//    cout << "  NetPrivate: inst: " << network->pathName(curInst) << " pin: " << network->pathName(curPin) << " net: " << network->pathName(net) << " visited" << endl;

    PinConnectedPinIterator* pcpIter = network->connectedPinIterator(curPin); 
    while( pcpIter->hasNext() ) {
      Pin* cpPin = pcpIter->next();

      // already pushed pin, then continue; 
      if( pinMap.find(cpPin) != pinMap.end()) {
        continue;
      }

//      cout << "connectedPin: " << network->pathName(cpPin) << endl;
     
      if( !network->isLeaf(cpPin) ) {
//        cout << network->pathName(cpPin) << " is not Leaf!" << endl;
        continue;
      } 

      Instance* cpInst = network->instance(cpPin);
      if( !cpInst ) {
        continue;
      }

      Net* cpNet = network->net(cpPin);
      if( network->isPower(cpNet) ) { 
        vddSet.insert(cpNet);
        continue; 
      }
      if( network->isGround(cpNet) ) {
        vssSet.insert(cpNet);
        continue;
      }

//      cout << "    NetPrivate: Push inst: " << network->pathName(cpInst) 
//        << " pin: " << network->pathName(cpPin); 
      const ConcretePin* cpin = reinterpret_cast<const ConcretePin*>(cpPin);
//      cout << " pIdx: " << cpin->vertexIndex() << " inserted!" << endl;
      if( isVisitPin[cpin->vertexIndex()] == 1) {
        continue;
      }
      
      isVisitPin[cpin->vertexIndex()] = 1; 

      string cpInstName = network->pathName(cpInst);
      pinMap.insert(cpPin);
      curNet.addPin( cpInstName.c_str(), network->portName(cpPin), 0);
      subNetCnt++; 
    }
  }
//  cout << "NetPrivate: netSearch: " << network->pathName (net) << " Done"<< endl;
}

// VDD/VSS net/pin push
void FillVddVssNet( sta::Sta* sta,
    Circuit::Circuit& ckt,
    defrData& defData, 
    unordered_set<Net*>& vddSet,
    unordered_set<Net*>& vssSet) {

  Network* network = sta->network();

  defiNet curDefVddNet(&defData);
  curDefVddNet.setName("VDD");
  curDefVddNet.setUse("POWER");
  unordered_set<Pin*> vddPinSet; 
  for(auto& curVddNet: vddSet) {
//    cout << "VDD: " << network->pathName(curVddNet) << endl;
    NetPinIterator* pinIterator = network->pinIterator(curVddNet);
    while( pinIterator->hasNext()) {
      Pin* curPin = pinIterator->next();
      // already pushed pins
      if( vddPinSet.find( curPin ) != vddPinSet.end()) {
        continue;
      }
      if(!network->isLeaf(curPin)) {
        continue;
      }
//      cout << "VDD's pin: " << network->pathName(curPin) << endl;
      Instance* inst = network->instance(curPin);

      string instName = network->pathName(inst );
      curDefVddNet.addPin( instName.c_str(), network->portName(curPin), 0); 
      vddPinSet.insert(curPin);
       
    }
  }
  if( curDefVddNet.numConnections() >= 1 ) {
    ckt.defNetStor.push_back(curDefVddNet);
  }


  defiNet curDefVssNet(&defData);
  curDefVssNet.setName("VSS");
  curDefVssNet.setUse("GROUND");
  unordered_set<Pin*> vssPinSet; 
  for(auto& curVssNet: vssSet) {
//    cout << "VSS: " << network->pathName(curVssNet) << endl;
    NetPinIterator* pinIterator = network->pinIterator(curVssNet);
    while( pinIterator->hasNext()) {
      Pin* curPin = pinIterator->next();
      // already pushed pins
      if( vssPinSet.find( curPin ) != vssPinSet.end()) {
        continue;
      }
      if(!network->isLeaf(curPin)) {
        continue;
      }
      Instance* inst = network->instance(curPin);

      string instName = network->pathName(inst );
      curDefVssNet.addPin( instName.c_str(), network->portName(curPin), 0); 
      vssPinSet.insert(curPin);
    }
  }
  if( curDefVssNet.numConnections() >= 1) {
    ckt.defNetStor.push_back(curDefVssNet);
  }
}

void FillMultiPinNetInfo ( sta::Sta* sta, 
    Circuit::Circuit& ckt,
    MultiPinNetInfo &multiPinNetInfo ) {
  
  sta::Network* network = sta->networkReader();
  InstanceNetIterator *netsIter = network->netIterator(network->topInstance()); 
  // Traverse Top Pins
  while(netsIter->hasNext()) {
    Net* net = netsIter->next();

    // skip for VDD/VSS nets
    if( network->isGround(net) || network->isPower(net)) {
      continue;
    }
     
    NetConnectedPinIterator* topPinIterator = network->connectedPinIterator(net);
    int topPinCnt = 0;
    while( topPinIterator->hasNext() ) {
      Pin* curPin = topPinIterator->next();
      if( !network->isTopLevelPort(curPin) ) {
        continue;
      }
      topPinCnt++;
    }

    // This is multiPinNet cases
    if(topPinCnt >= 2) {
//      cout << "multi Pin Net case! : " << topPinCnt  << endl;
      // Re-traverse and save data to multiPinInfo
      MultiPinNet mpNet;
      topPinIterator = network->connectedPinIterator(net);
      vector<string> netNameStor;
   
      // hashMap set for orig Pin 
      while( topPinIterator->hasNext() ) {
        Pin* curPin = topPinIterator->next();
        if( !network->isTopLevelPort(curPin) ) {
          continue;
        }
        // hashMap set for other pin
        multiPinNetInfo.multiPinMap[ curPin ] = multiPinNetInfo.multiPinNets.size();

        mpNet.pinStor.push_back( curPin );
        netNameStor.push_back( network->name(curPin) );
      }
      // sort netName and takes the most earlist one as netName 
      sort( netNameStor.begin(), netNameStor.end() );
      mpNet.netName = netNameStor[0];
      
      multiPinNetInfo.multiPinNets.push_back( mpNet );
    }
  }
}
