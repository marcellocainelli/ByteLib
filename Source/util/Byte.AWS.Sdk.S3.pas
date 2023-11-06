unit Byte.AWS.Sdk.S3;
interface
uses
  System.Classes,
  System.SysUtils,
  {$IFDEF FMX}
    FMX.StdCtrls,
  {$ELSE}
    Vcl.ComCtrls,
  {$ENDIF}
  AWS.S3, AWS.Client;
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
    function FilePath(AValue: String): iAWSs3;
    function ObjectName(AValue: String): iAWSs3;
    function Response: String;
    function ResponseCode: integer;
    function s3Config(AConfig: iAWSs3Config): iAWSs3;
    function ContentType(AValue: String): iAWSs3;

    function SendObject(AProgressBar: TProgressBar = nil): iAWSs3;
  end;
  TAWSs3 = class (TInterfacedObject, iAWSs3)
    protected
      FFilePath, FObjectName, FResponseMsg: String;
      FResponseCode: integer;
      FContentType: String;
      Fs3Config: iAWSs3Config;
    private
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iAWSs3;
      function FilePath(AValue: String): iAWSs3;
      function ObjectName(AValue: String): iAWSs3;
      function Response: String;
      function ResponseCode: integer;
      function s3Config(AConfig: iAWSs3Config): iAWSs3;
      function ContentType(AValue: String): iAWSs3;

      function SendObject(AProgressBar: TProgressBar = nil): iAWSs3;
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
function TAWSs3.ContentType(AValue: String): iAWSs3;
begin
  Result:= Self;
  FContentType:= AValue;
end;

constructor TAWSs3.Create;
begin
  FContentType:= 'application/zip';
end;
destructor TAWSs3.Destroy;
begin
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
  Fs3Config:= AConfig;
end;

function TAWSs3.SendObject(AProgressBar: TProgressBar): iAWSs3;
var
  vS3Obj: iS3Object;
  vS3Client: IS3Client;
  vs3Options: IS3Options;
  vObjRequest: IS3PutObjectRequest;
  vObjResponse: IS3PutObjectResponse;
  vStream: TMemoryStream;
begin
  try
    vStream:= TMemoryStream.Create;
    try
      vStream.LoadFromFile(FFilePath);
      vs3Options:= TS3Options.Create;
      vs3Options.Region:= Fs3Config.Region;
      vs3Options.AccessKeyId:= Fs3Config.AccName;
      vs3Options.SecretAccessKey:= Fs3Config.AccKey;

      vS3Client:= TS3Client.Create(vs3Options);

      vObjRequest:= TS3PutObjectRequest.Create(Fs3Config.BucketName, FObjectName, vStream);
      vObjRequest.ContentType:= FContentType;

      if AProgressBar <> nil then begin
        {$IFDEF FMX}
          AProgressBar.Value:= 0;
        {$ELSE}
          AProgressBar.Position:= 0;
        {$ENDIF}
        AProgressBar.Max:= vStream.Size;
        vObjRequest.OnSendData:=
          procedure(const AContentLength: Int64; AWriteCount: Int64; var AAbort: Boolean)
          begin
            {$IFDEF FMX}
              AProgressBar.Value:= AWriteCount;
            {$ELSE}
              AProgressBar.Position:= AWriteCount;
            {$ENDIF}
          end;
      end;

      vObjResponse:= vS3Client.PutObject(vObjRequest);

      FResponseCode:= vObjResponse.StatusCode;
      if FResponseCode = 200 then
        FResponseMsg:= 'Enviado com sucesso'
      else
        FResponseMsg:= vObjResponse.StatusText;
    finally
      vStream.Free;
    end;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;

end.
