unit Byte.Json;
interface
uses
  System.Classes,
  System.SysUtils,
  System.JSON;
type
  iJsonObj = interface
  ['{9AB362E5-43DE-4372-86F3-CCF2B18C19B6}']
    function SetJsonObj(AValue: TJSONObject)                      : iJsonObj;
    function ParseJsonValue(AValue: String)                       : iJsonObj;
    function ToString                                             : String;
    function ToJsonObject                                         : TJSONObject;
    function AddPair(const AKey: String; const AValue: String)    : iJsonObj; overload;
    function AddPair(const AKey: String; const AValue: integer)   : iJsonObj; overload;
    function AddPair(const AKey: String; const AValue: Boolean)   : iJsonObj; overload;
    function AddPair(const AKey: String; const AValue: Double)    : iJsonObj; overload;
    function AddPair(const AKey: String; const AValue: TDate)     : iJsonObj; overload;
    function AddPair(const AKey: String; const AValue: TDateTime) : iJsonObj; overload;
  end;
  TJsonObj = class(TInterfacedObject, iJsonObj)
    private
      FJsonObj: TJSONObject;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iJsonObj;
      function SetJsonObj(AValue: TJSONObject)                      : iJsonObj;
      function ParseJsonValue(AValue: String)                       : iJsonObj;
      function ToString                                             : String;
      function ToJsonObject                                         : TJSONObject;
      function AddPair(const AKey: String; const AValue: String)    : iJsonObj; overload;
      function AddPair(const AKey: String; const AValue: integer)   : iJsonObj; overload;
      function AddPair(const AKey: String; const AValue: Boolean)   : iJsonObj; overload;
      function AddPair(const AKey: String; const AValue: Double)    : iJsonObj; overload;
      function AddPair(const AKey: String; const AValue: TDate)     : iJsonObj; overload;
      function AddPair(const AKey: String; const AValue: TDateTime) : iJsonObj; overload;
  end;
  iJsonVal = interface
  ['{2FA1174D-1CE0-437E-85A6-DFACE259DA61}']
    function SetJsonVal(AValue: TJSONValue)                      : iJsonVal;
    function GetValueAsString(const AKey: String)                : String;
    function GetValue(const AKey: String; out AValue: Integer)   : iJsonVal; overload;
    function GetValue(const AKey: String; out AValue: Boolean)   : iJsonVal; overload;
    function GetValue(const AKey: String; out AValue: Double)    : iJsonVal; overload;
    function GetValue(const AKey: String; out AValue: TDateTime) : iJsonVal; overload;
    function RemovePair(AKey: String)                            : iJsonVal;
  end;
  TJsonVal = class(TInterfacedObject, iJsonVal)
    private
      FJsonValue: TJSONValue;
    public
      constructor Create(AValue: String);
      destructor Destroy; override;
      class function New(AValue: String): iJsonVal;
      function SetJsonVal(AValue: TJSONValue)                      : iJsonVal;
      function GetValueAsString(const AKey: String): String;
      function GetValue(const AKey: String; out AValue: Integer)   : iJsonVal; overload;
      function GetValue(const AKey: String; out AValue: Boolean)   : iJsonVal; overload;
      function GetValue(const AKey: String; out AValue: Double)    : iJsonVal; overload;
      function GetValue(const AKey: String; out AValue: TDateTime) : iJsonVal; overload;
      function RemovePair(AKey: String)                            : iJsonVal;
  end;
  iJsonArr = interface
  ['{EC6296C6-22F9-440E-B0E5-B32C9DAEF5B3}']
    function SetJsonVal(AValue: TJSONArray)                               : iJsonArr;
    function GetArrayAsString(AJsonValue: iJsonVal; const AKey: String)   : String; overload;
    function GetArrayAsString(AJsonValue: TJSONValue; const AKey: String) : String; overload;
    function Add(const AValue: string)                                    : iJsonArr; overload;
    function Add(const AValue: Integer)                                   : iJsonArr; overload;
    function Add(const AValue: Double)                                    : iJsonArr; overload;
    function Add(const AValue: Boolean)                                   : iJsonArr; overload;
    function Add(const AValue: TJSONObject)                               : iJsonArr; overload;
    function Add(const AValue: TJSONArray)                                : iJsonArr; overload;
    function Add(const AValue: iJsonObj)                                  : iJsonArr; overload;
    function AsString                                                     : String;
  end;
  TJsonArr = class(TInterfacedObject, iJsonArr)
    private
      FJsonArray: TJSONArray;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iJsonArr;
      function SetJsonVal(AValue: TJSONArray)                               : iJsonArr;
      function GetArrayAsString(AJsonValue: iJsonVal; const AKey: String)   : String; overload;
      function GetArrayAsString(AJsonValue: TJSONValue; const AKey: String) : String; overload;
      function Add(const AValue: string)                                    : iJsonArr; overload;
      function Add(const AValue: Integer)                                   : iJsonArr; overload;
      function Add(const AValue: Double)                                    : iJsonArr; overload;
      function Add(const AValue: Boolean)                                   : iJsonArr; overload;
      function Add(const AValue: TJSONObject)                               : iJsonArr; overload;
      function Add(const AValue: TJSONArray)                                : iJsonArr; overload;
      function Add(const AValue: iJsonObj)                                  : iJsonArr; overload;
      function AsString                                                     : String;
  end;
implementation
{ TJsonObj }
class function TJsonObj.New: iJsonObj;
begin
  Result:= Self.Create;
end;
constructor TJsonObj.Create;
begin
  FJsonObj:= TJSONObject.Create;
end;
destructor TJsonObj.Destroy;
begin
  if Assigned(FJsonObj) then
    FJsonObj.Free;
  inherited;
end;
function TJsonObj.SetJsonObj(AValue: TJSONObject): iJsonObj;
begin
  Result:= Self;
  FJsonObj:= AValue;
end;
function TJsonObj.ParseJsonValue(AValue: String): iJsonObj;
begin
  Result:= Self;
  FJsonObj:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(AValue), 0) as TJSONObject;
end;
function TJsonObj.ToJsonObject: TJSONObject;
begin
  Result:= FJsonObj;
end;
function TJsonObj.ToString: String;
begin
  Result:= FJsonObj.ToString;
end;

function TJsonObj.AddPair(const AKey: String; const AValue: Boolean): iJsonObj;
begin
  Result:= Self;
  {$IFNDEF VER340}
  FJsonObj.AddPair(AKey, AValue);
  {$ENDIF}
end;
function TJsonObj.AddPair(const AKey: String; const AValue: integer): iJsonObj;
begin
  Result:= Self;
  {$IFNDEF VER340}
  FJsonObj.AddPair(AKey, AValue);
  {$ENDIF}
end;
function TJsonObj.AddPair(const AKey, AValue: String): iJsonObj;
begin
  Result:= Self;
  FJsonObj.AddPair(AKey, AValue);
end;
function TJsonObj.AddPair(const AKey: String; const AValue: TDateTime): iJsonObj;
begin
  Result:= Self;
  {$IFNDEF VER340}
  FJsonObj.AddPair(AKey, AValue);
  {$ENDIF}
end;

function TJsonObj.AddPair(const AKey: String; const AValue: TDate): iJsonObj;
begin
  Result:= Self;
  {$IFNDEF VER340}
  FJsonObj.AddPair(AKey, AValue);
  {$ENDIF}
end;

function TJsonObj.AddPair(const AKey: String; const AValue: Double): iJsonObj;
begin
  Result:= Self;
  {$IFNDEF VER340}
  FJsonObj.AddPair(AKey, AValue);
  {$ENDIF}
end;
{ TJsonValue }
class function TJsonVal.New(AValue: String): iJsonVal;
begin
  Result:= Self.Create(AValue);
end;
constructor TJsonVal.Create(AValue: String);
begin
  FJsonValue:= TJSONObject.ParseJSONValue(AValue);
end;
destructor TJsonVal.Destroy;
begin
  if Assigned(FJsonValue) then
    FJsonValue.Free;
  inherited;
end;
function TJsonVal.SetJsonVal(AValue: TJSONValue): iJsonVal;
begin
  Result:= Self;
  FJsonValue:= AValue;
end;
function TJsonVal.GetValueAsString(const AKey: String): String;
var
  vValue: String;
begin
  FJsonValue.TryGetValue<String>(AKey, vValue);
  Result:= vValue;
  if vValue.IsEmpty then
    Result:= 'not found';
end;
function TJsonVal.GetValue(const AKey: String; out AValue: Integer): iJsonVal;
begin
  Result:= Self;
  FJsonValue.TryGetValue<Integer>(AKey, AValue);
end;
function TJsonVal.GetValue(const AKey: String; out AValue: Boolean): iJsonVal;
begin
  Result:= Self;
  FJsonValue.TryGetValue<Boolean>(AKey, AValue);
end;
function TJsonVal.GetValue(const AKey: String; out AValue: Double): iJsonVal;
begin
  Result:= Self;
  FJsonValue.TryGetValue<Double>(AKey, AValue);
end;
function TJsonVal.GetValue(const AKey: String; out AValue: TDateTime): iJsonVal;
begin
  Result:= Self;
  FJsonValue.TryGetValue<TDateTime>(AKey, AValue);
end;
function TJsonVal.RemovePair(AKey: String): iJsonVal;
var
  vJsonPair: TJSONPair;
begin
  Result:= Self;
  vJsonPair:= TJSONObject(FJsonValue).RemovePair(AKey);
  if Assigned(vJsonPair) then
    vJsonPair.Free;
end;
{ TJsonArr }
class function TJsonArr.New: iJsonArr;
begin
  Result:= Self.Create;
end;
constructor TJsonArr.Create;
begin
  FJsonArray:= TJSONArray.Create;
end;
destructor TJsonArr.Destroy;
begin
  if Assigned(FJsonArray) then
    FJsonArray.Free;
  inherited;
end;
function TJsonArr.SetJsonVal(AValue: TJSONArray): iJsonArr;
begin
  Result:= Self;
  FJsonArray:= AValue;
end;
function TJsonArr.GetArrayAsString(AJsonValue: iJsonVal; const AKey: String): String;
var
  vValue: String;
begin
  Result:= AJsonValue.GetValueAsString(AKey);
end;
function TJsonArr.GetArrayAsString(AJsonValue: TJSONValue; const AKey: String): String;
var
  vValue: String;
begin
  AJsonValue.TryGetValue<String>(AKey, vValue);
  Result:= vValue;
end;
function TJsonArr.Add(const AValue: Double): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue);
end;
function TJsonArr.Add(const AValue: Integer): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue);
end;
function TJsonArr.Add(const AValue: string): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue);
end;
function TJsonArr.Add(const AValue: TJSONArray): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue);
end;
function TJsonArr.Add(const AValue: TJSONObject): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue);
end;
function TJsonArr.Add(const AValue: Boolean): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue);
end;
function TJsonArr.Add(const AValue: iJsonObj): iJsonArr;
begin
  Result:= Self;
  FJsonArray.Add(AValue.ToJsonObject);
end;
function TJsonArr.AsString: String;
begin
  Result:= FJsonArray.ToString;
end;

end.
