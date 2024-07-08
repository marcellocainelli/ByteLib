unit NebulaZap.Service;
interface
uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.JSON,
  Byte.Json,
  RESTRequest4D,
  Dataset.Serialize,
  Byte.Lib,
  Forms,
  IdHttp,
  Graphics,
  ExtCtrls,
  pngimage, Controls;
const
  C_URL_API = 'https://integra-api.sistemasnebula.com.br';
  C_TIMEOUT = 10000;
type
  iNebulazapBase<T> = interface
    ['{1D1B1F01-8A9C-4B17-BF27-05186C056AA5}']
    function Get(const AResource: String; out AJSONResult: String): iNebulazapBase<T>;
    function Send(const AResource: String; AJSON: String): iNebulazapBase<T>;
    function Auth: iNebulazapBase<T>;
    function IntegratorID(AValue: String): iNebulazapBase<T>;
    function MerchantId(AValue: String): iNebulazapBase<T>;
    function MerchantPwd(AValue: String): iNebulazapBase<T>;
    function AccessToken: String;
    function &End : T;
  end;
  TNebulazapBase<T: IInterface> = class(TInterfacedObject, iNebulazapBase<T>)
  private
    [Weak]
    FParent: T;
    FMensagem, FMerchantId, FMerchantPwd, FIntegratorID, FAccessToken: String;
    FSucesso: Boolean;
    procedure GetAccessToken(AContent: String);
  public
    constructor Create(Parent: T);
    destructor Destroy; override;
    class function New(Parent: T): iNebulazapBase<T>;
    function &End : T;
    function Get(const AResource: String; out AJSONResult: String): iNebulazapBase<T>;
    function Send(const AResource: String; AJSON: String): iNebulazapBase<T>;
    function Auth: iNebulazapBase<T>;
    function IntegratorID(AValue: String): iNebulazapBase<T>;
    function MerchantId(AValue: String): iNebulazapBase<T>;
    function MerchantPwd(AValue: String): iNebulazapBase<T>;
    function AccessToken: String;
  end;
  iNebulaZap = interface
    ['{1EDD7045-3348-48AE-AB6A-AA936890B42C}']
    function NebulaZapBase: iNebulazapBase<iNebulaZap>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function EnviaMsg(ATelefone, AMsg: String): iNebulaZap;
    function EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iNebulaZap;
    function Boletos_EnviaPdf(ATelefone, AMsg, AFile, AFileName: String): iNebulaZap;
    function Instancia_Parear(AImage: TImage): String;
    function Instancia_Desconectar: iNebulaZap;
    function Status: iNebulaZap;
  end;
  TNebulaZap = class(TInterfacedObject, iNebulaZap)
    private
      FNebulazapBase: iNebulazapBase<iNebulaZap>;
      FSucesso: Boolean;
      FMensagem: String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
      procedure GetImageByUrl(URL: string; APicture: TPicture);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iNebulaZap;
      function NebulaZapBase: iNebulazapBase<iNebulaZap>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function EnviaMsg(ATelefone, AMsg: String): iNebulaZap;
      function EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iNebulaZap;
      function Boletos_EnviaPdf(ATelefone, AMsg, AFile, AFileName: String): iNebulaZap;
      function Instancia_Parear(AImage: TImage): String;
      function Instancia_Desconectar: iNebulaZap;
      function Status: iNebulaZap;
  end;
implementation
{ TPlugzapi<T> }
class function TNebulazapBase<T>.New(Parent: T): iNebulazapBase<T>;
begin
  Result:= Self.Create(Parent);
end;
constructor TNebulazapBase<T>.Create(Parent: T);
begin
  FParent:= Parent;
  FSucesso:= False;
  FMensagem:= '';
end;
destructor TNebulazapBase<T>.Destroy;
begin
  inherited;
end;
function TNebulazapBase<T>.&End: T;
begin
  Result:= FParent;
end;
function TNebulazapBase<T>.MerchantId(AValue: String): iNebulazapBase<T>;
begin
  Result:= Self;
  FMerchantId:= AValue;
end;
function TNebulazapBase<T>.MerchantPwd(AValue: String): iNebulazapBase<T>;
begin
  Result:= Self;
  FMerchantPwd:= AValue;
end;
function TNebulazapBase<T>.Get(const AResource: string; out AJSONResult: string): iNebulazapBase<T>;
var
  vResp: IResponse;
  vJSONResp: iJsonVal;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(C_URL_API)
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AcceptEncoding('UTF-8')
          .Get;
    if not (vResp.StatusCode = 200) then
      raise Exception.Create(vResp.Content);
    AJSONResult:= vResp.Content;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
function TNebulazapBase<T>.Send(const AResource: string; AJSON: string): iNebulazapBase<T>;
var
  vResp: IResponse;
  vJSONResp: iJsonVal;
begin
  Result:= Self;
  try
    TLib.CheckInternet;
    vResp:= TRequest.New.BaseURL(C_URL_API)
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AcceptEncoding('UTF-8')
          .AddBody(AJSON)
          .TokenBearer(FAccessToken)
          .Post;
    if not (vResp.StatusCode = 200) then begin
      raise Exception.Create('Não autorizado');
    end;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
function TNebulazapBase<T>.AccessToken: String;
begin
  Result:= FAccessToken;
end;
function TNebulazapBase<T>.Auth: iNebulazapBase<T>;
var
  vResp: IResponse;
  vJson: TJsonObject;
  vJSONResp: iJsonVal;
begin
  try
    if FMerchantId.Equals('') or FMerchantPwd.Equals('') then
      raise Exception.Create('Códigos de autenticação inválidos.');
    vJson:= TJSONObject.Create;
    try
      vJson.AddPair('merchantId', FMerchantId);
      vJson.AddPair('merchantPwd', FMerchantPwd);
      vResp:= TRequest.New.BaseURL(C_URL_API)
            .Timeout(C_TIMEOUT)
            .Resource('api/v4/auth')
            .ContentType('application/json')
            .AddHeader('IntegratorId', FIntegratorID)
            .AcceptEncoding('UTF-8')
            .AddBody(vJson.ToString)
            .Post;
      if not (vResp.StatusCode = 200) then begin
        raise Exception.Create('Não autorizado');
      end;
      GetAccessToken(vResp.Content);
    finally
      FreeAndNil(vJson);
    end;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
procedure TNebulazapBase<T>.GetAccessToken(AContent: String);
var
  vJsonObj, vObjData: TJSONObject;
  vSucesso: Boolean;
begin
  vJsonObj:= TJSONObject.ParseJSONValue(AContent) as TJSONObject;
  try
    vSucesso:= vJsonObj.GetValue<Boolean>('success');
    if vSucesso then begin
      vObjData:= vJsonObj.GetValue<TJSONObject>('data');
      FAccessToken:= vObjData.GetValue<string>('accessToken');
    end else
      raise Exception.Create('Erro ao obter o access token');
  finally
    vJsonObj.Free;
  end;
end;
function TNebulazapBase<T>.IntegratorID(AValue: String): iNebulazapBase<T>;
begin
  Result:= Self;
  FIntegratorID:= AValue;
end;
{ TNebulaZap }
class function TNebulaZap.New: iNebulaZap;
begin
  Result:= Self.Create;
end;

constructor TNebulaZap.Create;
begin
  FNebulazapBase:= TNebulazapBase<iNebulazap>.New(Self);
end;
destructor TNebulaZap.Destroy;
begin
  inherited;
end;
function TNebulaZap.NebulaZapBase: iNebulazapBase<iNebulaZap>;
begin
  Result:= FNebulazapBase;
end;
procedure TNebulaZap.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMensagem:= AMensagem;
end;
function TNebulaZap.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;
function TNebulaZap.Mensagem: String;
begin
  Result:= FMensagem;
end;
function TNebulaZap.EnviaMsg(ATelefone, AMsg: String): iNebulaZap;
var
  vResp: IResponse;
  vJSONResp: iJsonVal;
  vJSONObj: iJsonObj;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vJSONObj:= TJsonObj.New;
  try
    vJSONObj.AddPair('phone', ATelefone);
    vJSONObj.AddPair('message', AMsg);
    FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
          .Timeout(C_TIMEOUT)
          .Resource('api/v4/WhatsappMessage/send/message')
          .ContentType('application/json')
          .AcceptEncoding('UTF-8')
          .AddBody(vJSONObj.ToString)
          .TokenBearer(FNebulazapBase.AccessToken)
          .Post;
    if not (vResp.StatusCode = 200) then begin
      raise Exception.Create('Não autorizado');
    end;
    SetReqResult(True, 'Enviado com sucesso');
  except
    on E:Exception do
      SetReqResult(False, 'Erro ao enviar a mensagem:' + #13#10 + E.Message);
  end;
end;
function TNebulaZap.EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iNebulaZap;
var
  vBase64, vPath: string;
  vResp: IResponse;
  vStream: TMemoryStream;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  try
    FNebulazapBase.Auth;
    vPath:= APath;
    vPath:= vPath + '\' + AFileName;
    vStream:= TMemoryStream.Create;
    vStream.LoadFromfile(vPath);
    try
      vBase64:= TLib.Base64_Encode(vPath);
      if vBase64.Contains('Erro') then begin
        vBase64:= StringReplace(vBase64, 'Erro', '', [rfReplaceAll, rfIgnoreCase]);
        raise Exception.Create(vBase64);
      end;
      vResp:= TRequest.New.BaseURL(C_URL_API)
                .Timeout(C_TIMEOUT)
                .Resource('api/v4/WhatsappMessage/send/doc')
                .AddFile('file', vPath)
                .AddField('phone', ATelefone)
                .AddField('message', AMsg)
                .TokenBearer(FNebulazapBase.AccessToken)
                .Post;
      if not (vResp.StatusCode = 200) then begin
        raise Exception.Create('Não autorizado');
      end;
      SetReqResult(True, 'Enviado!');
    finally
      vStream.Free;
    end;
  except
    on E:Exception do
      SetReqResult(False, 'Erro ao enviar:' + #13#10 + E.Message);
  end;
end;
function TNebulaZap.Boletos_EnviaPdf(ATelefone, AMsg, AFile, AFileName: String): iNebulaZap;
var
  vPath, vFileName: String;
  vResp: IResponse;
  vStream: TMemoryStream;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vStream:= TMemoryStream.Create;
  try
    try
      FNebulazapBase.Auth;
      vPath:= ExtractFileDir(Application.ExeName) + '\TempFiles\';
      if not DirectoryExists(vPath) then
        ForceDirectories(vPath);
      vFileName:= vPath + AFileName;
      TLib.Base64_Decode(AFile, vStream);
      if FileExists(vFileName) then
        DeleteFile(vFileName);
      vStream.SaveToFile(vFileName);
      vResp:= TRequest.New.BaseURL(C_URL_API)
                .Timeout(C_TIMEOUT)
                .Resource('api/v4/WhatsappMessage/send/doc')
                .AddFile('file', vFileName)
                .AddField('phone', ATelefone)
                .AddField('message', AMsg)
                .TokenBearer(FNebulazapBase.AccessToken)
                .Post;
      if not (vResp.StatusCode = 200) then begin
        raise Exception.Create('Não autorizado');
      end;
      SetReqResult(True, 'Enviado!');
    except
      on E:Exception do
        SetReqResult(False, 'Erro ao enviar:' + #13#10 + E.Message);
    end;
  finally
    vStream.Free;
    DeleteFile(vFileName);
  end;
end;
function TNebulaZap.Instancia_Parear(AImage: TImage): String;
var
  vResp: IResponse;
  vJsonObj, vJsonData, vJsonResults: TJSONObject;
  vJsonSucesso: Boolean;
begin
  Result:= '';
  try
    FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/pairDevice')
              .TokenBearer(FNebulazapBase.AccessToken)
              .Get;
    if vResp.StatusCode = 200 then begin
      vJsonObj:= TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
      try
        vJsonSucesso:= vJsonObj.GetValue<boolean>('success');
        if not vJsonSucesso then
          raise Exception.Create('Indisponivel');
        try
          vJsonData:= vJsonObj.GetValue<TJSONObject>('data');
        except
          on E:Exception do
            raise Exception.Create('O dispositivo já está conectado.');
        end;
        vJsonResults:= vJsonData.GetValue<TJSONObject>('results');
        Result:= vJsonResults.GetValue<String>('qr_link');
        if Assigned(AImage) then
          GetImageByUrl(Result, AImage.Picture);
        SetReqResult(True, 'QrCode gerado com sucesso!');
      finally
        vJsonObj.Free;
      end;
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do
      SetReqResult(False, 'Erro ao solicitar QrCode:' + #13#10 + E.Message);
  end;
end;
procedure TNebulaZap.GetImageByUrl(URL: string; APicture: TPicture);
var
  Jpeg: TPNGImage;
  Strm: TMemoryStream;
  vIdHTTP : TIdHTTP;
begin
  if not DirectoryExists(ExtractFileDir(Application.ExeName) + '\qrcode') then
    ForceDirectories(ExtractFileDir(Application.ExeName) + '\qrcode');
  Screen.Cursor := crHourGlass;
  Jpeg := TPNGImage.Create;
  Strm := TMemoryStream.Create;
  vIdHTTP := TIdHTTP.Create(nil);
  try
    vIdHTTP.Get(URL, Strm);
    if (Strm.Size > 0) then
    begin
      Strm.SaveToFile(ExtractFileDir(Application.ExeName) + '\qrcode\qrcode.png');
      APicture.LoadFromFile(ExtractFileDir(Application.ExeName) + '\qrcode\qrcode.png');
    end;
  finally
    Strm.Free;
    Jpeg.Free;
    vIdHTTP.Free;
    Screen.Cursor := crDefault;
    if FileExists(ExtractFileDir(Application.ExeName) + '\qrcode\qrcode.png') then
      DeleteFile(ExtractFileDir(Application.ExeName) + '\qrcode\qrcode.png');
  end;
end;
function TNebulaZap.Instancia_Desconectar: iNebulaZap;
var
  vResp: IResponse;
  vJsonObj: TJSONObject;
  vJsonSucesso: Boolean;
begin
  Result:= Self;
  try
    FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/disconnectDevice')
              .TokenBearer(FNebulazapBase.AccessToken)
              .Get;
    if vResp.StatusCode = 200 then begin
      vJsonObj:= TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
      try
        vJsonSucesso:= vJsonObj.GetValue<boolean>('success');
        if not vJsonSucesso then
          raise Exception.Create('Nao foi possivel realizar o logout.');
      finally
        vJsonObj.Free;
      end;
      SetReqResult(True, 'Logout realizado com sucesso!');
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do
      SetReqResult(False, 'Erro ao desconectar:' + #13#10 + E.Message);
  end;
end;
function TNebulaZap.Status: iNebulaZap;
var
  vResp: IResponse;
  vJsonObj, vJsonRes: TJSONObject;
  vStatusLocal: boolean;
begin
  Result:= Self;
  vStatusLocal:= False;
  try
    FNebulazapBase.Auth;

    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/pairDevice')
              .TokenBearer(FNebulazapBase.AccessToken)
              .Get;

    if vResp.StatusCode = 200 then begin
      vJsonObj:= TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
      try
        try
          vJsonRes:= vJsonObj.GetValue<TJSONObject>('data');
        except

          vStatusLocal:= True;
          raise Exception.Create('Conectado');
        end;
      finally
        vJsonObj.Free;
      end;
      raise Exception.Create('Desconectado');
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do
      SetReqResult(vStatusLocal, E.Message);
  end;
end;
end.
