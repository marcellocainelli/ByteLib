unit NebulaZap.Service;
interface
uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.JSON,
  ShellAPI,
  Windows,
  Vcl.StdCtrls,
  Vcl.Controls,
  Byte.Json,
  RESTRequest4D,
  Dataset.Serialize,
  Byte.Lib,
  Forms,
  IdHttp,
  Graphics,
  ExtCtrls,
  pngimage;
const
  C_URL_API = 'https://integra-api.sistemasnebula.com.br';
  C_TIMEOUT = 30000;
type
  iNebulazapBase<T> = interface
    ['{1D1B1F01-8A9C-4B17-BF27-05186C056AA5}']
//    function Get(const AResource: String; out AJSONResult: String): iNebulazapBase<T>;
//    function Send(const AResource: String; AJSON: String): iNebulazapBase<T>;
    function Auth: String;
    function IntegratorID(AValue: String): iNebulazapBase<T>;
    function MerchantId(AValue: String): iNebulazapBase<T>;
    function MerchantPwd(AValue: String): iNebulazapBase<T>;
//    procedure AccessToken(AValue: String);
    function &End : T;
  end;
  TNebulazapBase<T: IInterface> = class(TInterfacedObject, iNebulazapBase<T>)
  private
    [Weak]
    FParent: T;
    FMensagem, FMerchantId, FMerchantPwd, FIntegratorID, FAccessToken: String;
    FSucesso: Boolean;
    function GetAccessToken(AContent: String): String;
  public
    constructor Create(Parent: T);
    destructor Destroy; override;
    class function New(Parent: T): iNebulazapBase<T>;
    function &End : T;
//    function Get(const AResource: String; out AJSONResult: String): iNebulazapBase<T>;
//    function Send(const AResource: String; AJSON: String): iNebulazapBase<T>;
    function Auth: String;
    function IntegratorID(AValue: String): iNebulazapBase<T>;
    function MerchantId(AValue: String): iNebulazapBase<T>;
    function MerchantPwd(AValue: String): iNebulazapBase<T>;
//    procedure AccessToken(AValue: String);
  end;
  iNebulaZap = interface
    ['{1EDD7045-3348-48AE-AB6A-AA936890B42C}']
    function NebulaZapBase: iNebulazapBase<iNebulaZap>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function EnviaMsg(ATelefone, AMsg: String): iNebulaZap;
    function EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iNebulaZap;
    function Boletos_EnviaPdf(ATelefone, AMsg, AFile, AFileName: String): iNebulaZap;
    function Instancia_Parear(AImage: TImage): String; overload;
    function Instancia_Parear(AImage: TImage; ALabel: TLabel): String; overload;
    function Instancia_Desconectar: iNebulaZap;
    function Status: iNebulaZap;
  end;
  TNebulaZap = class(TInterfacedObject, iNebulaZap)
    private
      FNebulazapBase: iNebulazapBase<iNebulaZap>;
      FSucesso: Boolean;
      FMensagem: String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
      procedure GetImageByUrl(URL: string; APicture: TPicture); overload;
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
      function Instancia_Parear(AImage: TImage): String; overload;
      function Instancia_Parear(AImage: TImage; ALabel: TLabel): String; overload;
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
//function TNebulazapBase<T>.Get(const AResource: string; out AJSONResult: string): iNebulazapBase<T>;
//var
//  vResp: IResponse;
//  vJSONResp: iJsonVal;
//begin
//  Result:= Self;
//  try
//    vResp:= TRequest.New.BaseURL(C_URL_API)
//          .Timeout(C_TIMEOUT)
//          .Resource(AResource)
////          .ContentType('application/json')
////          .AcceptEncoding('UTF-8')
//          .Get;
//    if not (vResp.StatusCode = 200) then
//      raise Exception.Create(vResp.Content);
//    AJSONResult:= vResp.Content;
//  except
//    on E:Exception do
//      raise Exception.Create(E.Message);
//  end;
//end;
//function TNebulazapBase<T>.Send(const AResource: string; AJSON: string): iNebulazapBase<T>;
//var
//  vResp: IResponse;
//  vJSONResp: iJsonVal;
//begin
//  Result:= Self;
//  try
//    TLib.CheckInternet;
//    vResp:= TRequest.New.BaseURL(C_URL_API)
//          .Timeout(C_TIMEOUT)
//          .Resource(AResource)
////          .ContentType('application/json')
////          .AcceptEncoding('UTF-8')
//          .AddBody(AJSON)
//          .TokenBearer(FAccessToken)
//          .Post;
//    if not (vResp.StatusCode = 200) then begin
//      raise Exception.Create('Não autorizado');
//    end;
//  except
//    on E:Exception do
//      raise Exception.Create(E.Message);
//  end;
//end;
//procedure TNebulazapBase<T>.AccessToken(AValue: String);
//begin
//  FAccessToken:= AValue;
//end;
function TNebulazapBase<T>.Auth: String;
var
  vResp: IResponse;
  vJson: TJsonObject;
  vJSONResp: iJsonVal;
begin
  Result:= '';
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
//            .ContentType('application/json')
            .AddHeader('IntegratorId', FIntegratorID)
//            .AcceptEncoding('UTF-8')
            .AddBody(vJson.ToString)
            .Post;
      if not (vResp.StatusCode = 200) then begin
        raise Exception.Create('Não autorizado');
      end;
      Result:= GetAccessToken(vResp.Content);
    finally
      FreeAndNil(vJson);
    end;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
function TNebulazapBase<T>.GetAccessToken(AContent: String): String;
var
  vJsonObj, vObjData: TJSONObject;
  vSucesso: Boolean;
begin
  Result:= '';
  vJsonObj:= TJSONObject.ParseJSONValue(AContent) as TJSONObject;
  try
    vSucesso:= vJsonObj.GetValue<Boolean>('success');
    if vSucesso then begin
      vObjData:= vJsonObj.GetValue<TJSONObject>('data');
      Result:= vObjData.GetValue<string>('accessToken');
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
  vAuth: String;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vJSONObj:= TJsonObj.New;
  try
    vJSONObj.AddPair('phone', ATelefone);
    vJSONObj.AddPair('message', AMsg);
    vAuth:= FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
          .Timeout(C_TIMEOUT)
          .Resource('api/v4/WhatsappMessage/send/message')
//          .ContentType('application/json')
//          .AcceptEncoding('UTF-8')
          .AddBody(vJSONObj.ToString)
          .TokenBearer(vAuth)
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
  vAuth: String;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  try
    vAuth:= FNebulazapBase.Auth;
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
                .TokenBearer(vAuth)
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
  vAuth: String;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vStream:= TMemoryStream.Create;
  try
    try
      vAuth:= FNebulazapBase.Auth;
      vPath:= System.SysUtils.ExtractFileDir(Application.ExeName) + '\TempFiles\';
      if not System.SysUtils.DirectoryExists(vPath) then
        System.SysUtils.ForceDirectories(vPath);
      vFileName:= vPath + AFileName;
      TLib.Base64_Decode(AFile, vStream);
      if System.SysUtils.FileExists(vFileName) then
        System.SysUtils.DeleteFile(vFileName);
      vStream.SaveToFile(vFileName);
      vResp:= TRequest.New.BaseURL(C_URL_API)
                .Timeout(C_TIMEOUT)
                .Resource('api/v4/WhatsappMessage/send/doc')
                .AddFile('file', vFileName)
                .AddField('phone', ATelefone)
                .AddField('message', AMsg)
                .TokenBearer(vAuth)
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
    System.SysUtils.DeleteFile(vFileName);
  end;
end;
function TNebulaZap.Instancia_Parear(AImage: TImage): String;
var
  vResp: IResponse;
  vJsonObj, vJsonData, vJsonResults: TJSONObject;
  vJsonSucesso: Boolean;
  vAuth: String;
begin
  Result:= '';
  try
    vAuth:= FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/pairDevice')
              .TokenBearer(vAuth)
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
          GetImageByUrl(Result, AImage.Picture)
        else
          ShellExecute(0, 'open', PChar(Result), nil, nil, SW_SHOWNORMAL);
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
  IdHTTP: TIdHTTP;
  Stream: TMemoryStream;
  JpegImage: TPNGImage;
begin
  IdHTTP := TIdHTTP.Create(nil);
  Stream := TMemoryStream.Create;
  JpegImage := TPNGImage.Create;
  try
    try
      // Definir o User-Agent para simular um navegador
      IdHTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';

      // Baixa a imagem do URL
      IdHTTP.Get(URL, Stream);

      // Reposiciona o stream para o início
      Stream.Position := 0;

      // Carrega a imagem do stream para o TJPEGImage
      JpegImage.LoadFromStream(Stream);

      // Atribui a imagem ao TImage
      APicture.Assign(JpegImage);
    except
      on E: Exception do
        raise Exception.Create('Erro ao carregar imagem: ' + E.Message);
    end;
  finally
    IdHTTP.Free;
    Stream.Free;
    JpegImage.Free;
  end;
end;

function TNebulaZap.Instancia_Parear(AImage: TImage; ALabel: TLabel): String;
var
  vResp: IResponse;
  vJsonObj, vJsonData, vJsonResults: TJSONObject;
  vJsonSucesso: Boolean;
  vAuth: String;
begin
  Result:= '';
  try
    vAuth:= FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/pairDevice')
              .TokenBearer(vAuth)
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
          GetImageByUrl(Result, AImage.Picture)
        else
          ShellExecute(0, 'open', PChar(Result), nil, nil, SW_SHOWNORMAL);
        if Assigned(ALabel) then
          TLabel(ALabel).Caption:= 'Expiração:' + IntToStr(vJsonResults.GetValue<integer>('qr_duration')) + ' segundos';
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

function TNebulaZap.Instancia_Desconectar: iNebulaZap;
var
  vResp: IResponse;
  vJsonObj: TJSONObject;
  vJsonSucesso: Boolean;
  vAuth: String;
begin
  Result:= Self;
  try
    vAuth:= FNebulazapBase.Auth;
    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/disconnectDevice')
              .TokenBearer(vAuth)
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
  vAuth: String;
begin
  Result:= Self;
  vStatusLocal:= False;
  try
    vAuth:= FNebulazapBase.Auth;

    vResp:= TRequest.New.BaseURL(C_URL_API)
              .Timeout(C_TIMEOUT)
              .Resource('api/v4/WhatsappMessage/pairDevice')
              .TokenBearer(vAuth)
              .Get;

    if vResp.StatusCode = 400 then begin
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
