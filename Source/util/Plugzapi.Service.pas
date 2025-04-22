unit Plugzapi.Service;
interface
uses
  System.SysUtils,
  System.Classes,
  Byte.Json,
  RESTRequest4D,
  Dataset.Serialize,
  Byte.Lib;
const
  C_URL_API = 'https://api-windows.plugzapi.com.br/instances/%s/token/%s';
  C_TIMEOUT = 10000;

type
  iPlugzapi<T> = interface
    ['{1D1B1F01-8A9C-4B17-BF27-05186C056AA5}']
    function Instancia(AValue: String): iPlugzapi<T>;
    function Token(AValue: String): iPlugzapi<T>;
    function Bearer(AValue: String): iPlugzapi<T>;
    function ClientToken(AValue: String): iPlugzapi<T>;
    function Get(const AResource: String; out AJSONResult: String): iPlugzapi<T>;
    function Send(const AResource: String; AJSON: String): iPlugzapi<T>;
    function &End : T;
  end;
  TPlugzapi<T: IInterface> = class(TInterfacedObject, iPlugzapi<T>)
  private
    [Weak]
    FParent: T;
    FInstancia, FToken, FBearer, FClientToken, FMensagem: String;
    FSucesso: Boolean;
  public
    constructor Create(Parent: T);
    destructor Destroy; override;
    class function New(Parent: T): iPlugzapi<T>;
    function &End : T;
    function Instancia(AValue: String): iPlugzapi<T>;
    function Token(AValue: String): iPlugzapi<T>;
    function Bearer(AValue: String): iPlugzapi<T>;
    function ClientToken(AValue: String): iPlugzapi<T>;
    function Get(const AResource: String; out AJSONResult: String): iPlugzapi<T>;
    function Send(const AResource: String; AJSON: String): iPlugzapi<T>;
  end;
  iPlugzapiInstancia = interface
    ['{9B2152F0-19F5-4898-8A74-7280F1763A1D}']
    function Plugzapi: iPlugzapi<iPlugzapiInstancia>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function Status: boolean;
    function QrCode: String;
  end;
  TPlugzapiInstancia = class(TInterfacedObject, iPlugzapiInstancia)
    private
      FPlugzapi: iPlugzapi<iPlugzapiInstancia>;
      FSucesso: Boolean;
      FMensagem: String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iPlugzapiInstancia;
      function Plugzapi: iPlugzapi<iPlugzapiInstancia>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function Status: boolean;
      function QrCode: String;
  end;
  iPlugzapiMsg = interface
    ['{1EDD7045-3348-48AE-AB6A-AA936890B42C}']
    function Plugzapi: iPlugzapi<iPlugzapiMsg>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function EnviaMsg(ATelefone, AMsg: String): iPlugzapiMsg;
    function EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iPlugzapiMsg;
  end;
  TPlugzapiMsg = class(TInterfacedObject, iPlugzapiMsg)
    private
      FPlugzapi: iPlugzapi<iPlugzapiMsg>;
      FSucesso: Boolean;
      FMensagem: String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iPlugzapiMsg;
      function Plugzapi: iPlugzapi<iPlugzapiMsg>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function EnviaMsg(ATelefone, AMsg: String): iPlugzapiMsg;
      function EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iPlugzapiMsg;
  end;
implementation
{ TPlugzapi<T> }
class function TPlugzapi<T>.New(Parent: T): iPlugzapi<T>;
begin
  Result:= Self.Create(Parent);
end;

constructor TPlugzapi<T>.Create(Parent: T);
begin
  FParent:= Parent;
  FSucesso:= False;
  FMensagem:= '';
end;
destructor TPlugzapi<T>.Destroy;
begin
  inherited;
end;
function TPlugzapi<T>.&End: T;
begin
  Result:= FParent;
end;
function TPlugzapi<T>.Token(AValue: string): iPlugzapi<T>;
begin
  Result:= Self;
  FToken:= AValue;
end;
function TPlugzapi<T>.Instancia(AValue: string): iPlugzapi<T>;
begin
  Result:= Self;
  FInstancia:= AValue;
end;

function TPlugzapi<T>.Bearer(AValue: String): iPlugzapi<T>;
begin
  Result:= Self;
  FBearer:= AValue;
end;

function TPlugzapi<T>.ClientToken(AValue: String): iPlugzapi<T>;
begin
  Result:= Self;
  FClientToken:= AValue;
end;

function TPlugzapi<T>.Get(const AResource: string; out AJSONResult: string): iPlugzapi<T>;
var
  vResp: IResponse;
  vJSONResp: iJsonVal;
begin
  Result:= Self;
  try
    TLib.CheckInternet;
    vResp:= TRequest.New.BaseURL(Format(C_URL_API,[FInstancia, FToken]))
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AddHeader('Client-Token', FClientToken)
          .AcceptEncoding('UTF-8')
          .TokenBearer(FBearer)
          .Get;
    if not (vResp.StatusCode = 200) then begin
      vJSONResp:= TJsonVal.New(vResp.Content);
      raise Exception.Create(vJSONResp.GetValueAsString('Erro'));
    end;
    AJSONResult:= vResp.Content;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
function TPlugzapi<T>.Send(const AResource: string; AJSON: string): iPlugzapi<T>;
var
  vResp: IResponse;
  vJSONResp: iJsonVal;
begin
  Result:= Self;
  try
    TLib.CheckInternet;
    vResp:= TRequest.New.BaseURL(Format(C_URL_API,[FInstancia, FToken]))
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AddHeader('Client-Token', FClientToken)
          .AcceptEncoding('UTF-8')
          .AddBody(AJSON)
          .TokenBearer(FBearer)
          .Post;
    if not (vResp.StatusCode = 200) then begin
      vJSONResp:= TJsonVal.New(vResp.Content);
      raise Exception.Create(vJSONResp.GetValueAsString('Erro'));
    end;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;

{ TPlugzapiInstancia }

class function TPlugzapiInstancia.New: iPlugzapiInstancia;
begin
  Result:= Self.Create;
end;

constructor TPlugzapiInstancia.Create;
begin
  FPlugzapi:= TPlugzapi<iPlugzapiInstancia>.New(Self);
end;

destructor TPlugzapiInstancia.Destroy;
begin
  inherited;
end;

function TPlugzapiInstancia.Plugzapi: iPlugzapi<iPlugzapiInstancia>;
begin
  Result:= FPlugzapi;
end;
function TPlugzapiInstancia.QrCode: string;
var
  vJSONResp: iJsonVal;
  vJSONResult: string;
begin
  try
    FPlugzapi.Get('qr-code/image', vJSONResult);
    vJSONResp:= TJsonVal.New(vJSONResult);
    if vJSONResp.GetValueAsString('connected').Equals('true') then
      raise Exception.Create('Já está conectado!')
    else
      Result:= vJSONResult;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TPlugzapiInstancia.Status: boolean;
var
  vJSONResp: iJsonVal;
  vJSONResult: string;
begin
  Result:= False;
  try
    FPlugzapi.Get('status', vJSONResult);
    vJSONResp:= TJsonVal.New(vJSONResult);
    Result:= vJSONResp.GetValueAsString('connected').Equals('true');
  except
    on E:Exception do
      raise Exception.Create('Erro:' + #13#10 + E.Message);
  end;
end;
function TPlugzapiInstancia.Mensagem: String;
begin
  Result:= FMensagem;
end;
function TPlugzapiInstancia.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

procedure TPlugzapiInstancia.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMensagem:= AMensagem;
end;

{ TPlugzapiMsg }

class function TPlugzapiMsg.New: iPlugzapiMsg;
begin
  Result:= Self.Create;
end;

constructor TPlugzapiMsg.Create;
begin
  FPlugzapi:= TPlugzapi<iPlugzapiMsg>.New(Self);
end;

destructor TPlugzapiMsg.Destroy;
begin
  inherited;
end;

function TPlugzapiMsg.Plugzapi: iPlugzapi<iPlugzapiMsg>;
begin
  Result:= FPlugzapi;
end;

procedure TPlugzapiMsg.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMensagem:= AMensagem;
end;

function TPlugzapiMsg.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

function TPlugzapiMsg.Mensagem: String;
begin
  Result:= FMensagem;
end;

function TPlugzapiMsg.EnviaMsg(ATelefone, AMsg: String): iPlugzapiMsg;
var
  vJSONObj: iJsonObj;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vJSONObj:= TJsonObj.New;
  try
    vJSONObj.AddPair('phone', '55' + ATelefone);
    vJSONObj.AddPair('message', AMsg);
    vJSONObj.AddPair('delayMessage', TLib.GetRandomNumber(5000, 30000));
    FPlugzapi.Send('send-text', vJSONObj.ToString);
    SetReqResult(True, 'Enviado com sucesso');
  except
    on E:Exception do
      SetReqResult(False, 'Erro ao enviar a mensagem:' + #13#10 + E.Message);
  end;
end;
function TPlugzapiMsg.EnviaPdf(ATelefone, AMsg, APath, AFileName: String): iPlugzapiMsg;
var
  vJSONObj: iJsonObj;
  vBase64, vPath: string;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vJSONObj:= TJsonObj.New;
  try
    vPath:= APath;
    if not AFileName.Equals('Teste') then
      vPath:= vPath + '\' + AFileName;
    vBase64:= TLib.Base64_Encode(vPath);
    if vBase64.Contains('Erro') then begin
      vBase64:= StringReplace(vBase64, 'Erro', '', [rfReplaceAll, rfIgnoreCase]);
      raise Exception.Create(vBase64);
    end;
    vJSONObj.AddPair('phone', '55' + ATelefone);
    vJSONObj.AddPair('document', 'data:file/pdf;base64,' + vBase64);
    vJSONObj.AddPair('fileName', AFileName);
    vJSONObj.AddPair('delayMessage', TLib.GetRandomNumber(5000, 30000));
    vJSONObj.AddPair('caption', AMsg);
    FPlugzapi.Send('send-document/pdf', vJSONObj.ToString);
//    EnviaMsg(ATelefone, AMsg);
  except
    on E:Exception do
      SetReqResult(False, 'Erro ao enviar o arquivo:' + #13#10 + E.Message);
  end;
end;

end.
