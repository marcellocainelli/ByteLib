unit Byte.AWS.S3;
interface
uses
  System.Classes,
  System.SysUtils,
  Data.Cloud.CloudAPI,
  Data.Cloud.AmazonAPI;
type
  iAWSs3Config = interface
    ['{3E51350F-1063-4B11-9F1E-F3CBD8D03900}']
    function Region(AValue: String): iAWSs3Config; overload;
    function Region: String; overload;
    function AccName(AValue: String): iAWSs3Config; overload;
    function AccName: String; overload;
    function AccKey(AValue: String): iAWSs3Config; overload;
    function AccKey: String; overload;
    function BucketName(AValue: String): iAWSs3Config; overload;
    function BucketName: String; overload;
  end;
  TAWSs3Config = class (TInterfacedObject, iAWSs3Config)
    protected
      FRegion, FAccName, FAccKey, FBucketName: String;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iAWSs3Config;
      function Region(AValue: String): iAWSs3Config; overload;
      function Region: String; overload;
      function AccName(AValue: String): iAWSs3Config; overload;
      function AccName: String; overload;
      function AccKey(AValue: String): iAWSs3Config; overload;
      function AccKey: String; overload;
      function BucketName(AValue: String): iAWSs3Config; overload;
      function BucketName: String; overload;
  end;
  iAWSs3 = interface
    ['{5C313EBB-54BA-4899-9D99-60D2C0CA2701}']
    function SendObject: iAWSs3; overload;
    function SendObject(AStream: TStream): iAWSs3; overload;
    function GetObject: iAWSs3; overload;
    function GetObjectStream: TStream; overload;
    function GetObjectMetaDataValue(AValue: String): String;
    function DeleteObject: iAWSs3;
    function FilePath(AValue: String): iAWSs3;
    function ObjectName(AValue: String): iAWSs3;
    function Response: String;
    function ResponseCode: integer;
    function s3Config(AConfig: iAWSs3Config): iAWSs3;
    function AddHeader(AKey, AValue: String): iAWSs3;
    function AddMetaData(AKey, AValue: String): iAWSs3;
    function CreateFolder: iAWSs3;
  end;
  TAWSs3 = class (TInterfacedObject, iAWSs3)
    protected
      FAmazonConnectionInfo: TAmazonConnectionInfo;
      FFilePath, FObjectName, FBucketName, FRegion, FResponseMsg: String;
      FResponseCode: integer;
      FHeader, FMetaDados: TStringList;
    private
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iAWSs3;
      function SendObject: iAWSs3; overload;
      function SendObject(AStream: TStream): iAWSs3; overload;
      function GetObject: iAWSs3; overload;
      function GetObjectStream: TStream; overload;
      function DeleteObject: iAWSs3;
      function GetObjectMetaDataValue(AValue: String): String;
      function FilePath(AValue: String): iAWSs3;
      function ObjectName(AValue: String): iAWSs3;
      function Response: String;
      function ResponseCode: integer;
      function s3Config(AConfig: iAWSs3Config): iAWSs3;
      function AddHeader(AKey, AValue: String): iAWSs3;
      function AddMetaData(AKey, AValue: String): iAWSs3;
      function CreateFolder: iAWSs3;
  end;
implementation
{ TAWSs3Config }
class function TAWSs3Config.New: iAWSs3Config;
begin
  Result:= Self.Create;
end;
constructor TAWSs3Config.Create;
begin
  FRegion:= 'us-east-1';
end;
destructor TAWSs3Config.Destroy;
begin
  inherited;
end;
function TAWSs3Config.AccKey(AValue: String): iAWSs3Config;
begin
  Result:= Self;
  FAccKey:= AValue;
end;
function TAWSs3Config.AccName(AValue: String): iAWSs3Config;
begin
  Result:= Self;
  FAccName:= AValue;
end;
function TAWSs3Config.Region(AValue: String): iAWSs3Config;
begin
  Result:= Self;
  FRegion:= AValue;
end;
function TAWSs3Config.AccKey: String;
begin
  Result:= FAccKey;
end;
function TAWSs3Config.AccName: String;
begin
  Result:= FAccName;
end;
function TAWSs3Config.Region: String;
begin
  Result:= FRegion;
end;
function TAWSs3Config.BucketName: String;
begin
  Result:= FBucketName;
end;
function TAWSs3Config.BucketName(AValue: String): iAWSs3Config;
begin
  Result:= Self;
  FBucketName:= AValue;
end;
{ TAWSs3 }
class function TAWSs3.New: iAWSs3;
begin
  Result:= Self.Create;
end;
constructor TAWSs3.Create;
begin
  FAmazonConnectionInfo:= TAmazonConnectionInfo.Create(nil);
end;

destructor TAWSs3.Destroy;
begin
  FAmazonConnectionInfo.Free;
  FHeader.Free;
  FMetaDados.Free;
  inherited;
end;
function TAWSs3.ObjectName(AValue: String): iAWSs3;
begin
  Result:= Self;
  FObjectName:= AValue;
end;
function TAWSs3.FilePath(AValue: String): iAWSs3;
begin
  Result:= Self;
  FFilePath:= AValue;
end;

function TAWSs3.Response: String;
begin
  Result:= FResponseMsg;
end;
function TAWSs3.ResponseCode: integer;
begin
  Result:= FResponseCode;
end;
function TAWSs3.s3Config(AConfig: iAWSs3Config): iAWSs3;
begin
  Result:= Self;
  FAmazonConnectionInfo.ConsistentRead:= True;
  FAmazonConnectionInfo.Region:= AConfig.Region;
  FAmazonConnectionInfo.AccountName:= AConfig.AccName;
  FAmazonConnectionInfo.AccountKey:= AConfig.AccKey;
  FAmazonConnectionInfo.AutoDetectBucketRegion:= True;
  FBucketName:= AConfig.BucketName;
  FRegion:= AConfig.Region;
end;

function TAWSs3.SendObject: iAWSs3;
var
  vStorageService: TAmazonStorageService;
  vStream: TBytesStream;
  vCloudResponse: TCloudResponseInfo;
begin
  Result:= Self;
  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  vStream:= TBytesStream.Create;
  try
    vStream.LoadFromFile(FFilePath);
    if vStorageService.UploadObject(FBucketName,
                                    FObjectName,
                                    vStream.Bytes,
                                    False,
                                    FMetaDados,
                                    FHeader,
                                    amzbaNotSpecified,
                                    vCloudResponse) then
      FResponseMsg:= 'Enviado com sucesso'
    else
      FResponseMsg:= 'Erro: ' + vCloudResponse.StatusMessage;
    FResponseCode:= vCloudResponse.StatusCode;
  finally
    vStorageService.Free;
    vStream.Free;
    vCloudResponse.Free;
  end;
end;

function TAWSs3.SendObject(AStream: TStream): iAWSs3;
var
  vStorageService: TAmazonStorageService;
  vStream: TBytesStream;
  vCloudResponse: TCloudResponseInfo;
begin
  Result:= Self;
  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  vStream:= TBytesStream.Create;
  try
    vStream.LoadFromStream(AStream);
    if vStorageService.UploadObject(FBucketName,
                                    FFilePath + FObjectName,
                                    vStream.Bytes,
                                    False,
                                    FMetaDados,
                                    FHeader,
                                    amzbaNotSpecified,
                                    vCloudResponse) then
      FResponseMsg:= 'Enviado com sucesso'
    else
      FResponseMsg:= 'Erro: ' + vCloudResponse.StatusMessage;
    FResponseCode:= vCloudResponse.StatusCode;
  finally
    vStorageService.Free;
    vStream.Free;
    vCloudResponse.Free;
  end;
end;

function TAWSs3.GetObject: iAWSs3;
var
  vStorageService: TAmazonStorageService;
  vCloudResponse: TCloudResponseInfo;
  vStream: TMemoryStream;
begin
  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  vStream:= TMemoryStream.Create;
  try
    if vStorageService.GetObject(FBucketName,
                                    FObjectName,
                                    TAmazonGetObjectOptionals.Create,
                                    vStream,
                                    vCloudResponse,
                                    FRegion) then
      FResponseMsg:= 'Enviado com sucesso'
    else
      FResponseMsg:= 'Erro: ' + vCloudResponse.StatusMessage;
    FResponseCode:= vCloudResponse.StatusCode;
    vStream.SaveToFile(FFilePath);
  finally
    vStorageService.Free;
    vCloudResponse.Free;
    vStream.Free;
  end;
end;

function TAWSs3.GetObjectStream: TStream;
var
  vStorageService: TAmazonStorageService;
  vCloudResponse: TCloudResponseInfo;
  vStream: TMemoryStream;
begin
  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  vStream:= TMemoryStream.Create;
  try
    if vStorageService.GetObject(FBucketName,
                                    FObjectName,
                                    TAmazonGetObjectOptionals.Create,
                                    vStream,
                                    vCloudResponse,
                                    FRegion) then
      FResponseMsg:= 'Enviado com sucesso'
    else
      FResponseMsg:= 'Erro: ' + vCloudResponse.StatusMessage;
    FResponseCode:= vCloudResponse.StatusCode;
    Result:= vStream;
  finally
    vStorageService.Free;
    vCloudResponse.Free;
  end;
end;

function TAWSs3.GetObjectMetaDataValue(AValue: String): String;
var
  vStorageService: TAmazonStorageService;
  vStringList: TStrings;
  vCloudResponse: TCloudResponseInfo;
  vAmazonGetObjectOptionals: TAmazonGetObjectOptionals;
begin
  Result:= '';

  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  try
    vStringList:= vStorageService.GetObjectMetadata(FBucketName,
                                                    FObjectName,
                                                    vAmazonGetObjectOptionals,
                                                    vCloudResponse,
                                                    FRegion);
    Result:= vStringList.Values[AValue];
  finally
    vStorageService.Free;
    vStringList.Free;
    vCloudResponse.Free;
  end;
end;

function TAWSs3.AddHeader(AKey, AValue: String): iAWSs3;
begin
  Result:= Self;
  if not Assigned(FHeader) then
    FHeader:= TStringList.Create;

  FHeader.Values[AKey]:= AValue;
end;

function TAWSs3.AddMetaData(AKey, AValue: String): iAWSs3;
begin
  Result:= Self;
  if not Assigned(FMetaDados) then
    FMetaDados:= TStringList.Create;

  FMetaDados.Values[AKey]:= AValue;
end;

function TAWSs3.CreateFolder: iAWSs3;
var
  vStorageService: TAmazonStorageService;
  vCloudResponse: TCloudResponseInfo;
  vFolder: String;
begin
  Result:= Self;
  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  try
    vFolder:= Format('%s%s/', [FFilePath, FObjectName]);
    if vStorageService.UploadObject(FBucketName,
                                    vFolder,
                                    nil,
                                    False,
                                    FMetaDados,
                                    FHeader,
                                    amzbaNotSpecified,
                                    vCloudResponse) then
      FResponseMsg:= 'Criado com sucesso'
    else
      FResponseMsg:= 'Erro: ' + vCloudResponse.StatusMessage;
    FResponseCode:= vCloudResponse.StatusCode;
  finally
    vStorageService.Free;
    vCloudResponse.Free;
  end;
end;

function TAWSs3.DeleteObject: iAWSs3;
var
  vStorageService: TAmazonStorageService;
  vCloudResponse: TCloudResponseInfo;
  vObjectName: String;
begin
  Result:= Self;
  vStorageService:= TAmazonStorageService.Create(FAmazonConnectionInfo);
  vCloudResponse:= TCloudResponseInfo.Create;
  vObjectName:= Format('%s%s', [FFilePath, FObjectName]);
  try
    if vStorageService.DeleteObject(FBucketName,
                                    vObjectName,
                                    vCloudResponse) then
      FResponseMsg:= 'Deletado com sucesso'
    else
      FResponseMsg:= 'Erro: ' + vCloudResponse.StatusMessage;
    FResponseCode:= vCloudResponse.StatusCode;
  finally
    vStorageService.Free;
    vCloudResponse.Free;
  end;
end;

end.

