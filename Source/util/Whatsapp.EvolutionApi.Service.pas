unit Whatsapp.EvolutionApi.Service;
interface
uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Byte.Json,
  RESTRequest4D,
  Dataset.Serialize,
  Byte.Lib;
const
  C_TIMEOUT = 20000;
type
  iEvolutionApi<T> = interface
    ['{1D1B1F01-8A9C-4B17-BF27-05186C056AA5}']
    function Url(AValue: String): iEvolutionApi<T>; overload;
    function Url: String; overload; overload;
    function Instancia(AValue: String): iEvolutionApi<T>; overload;
    function Instancia: String; overload;
    function Token(AValue: String): iEvolutionApi<T>; overload;
    function Token: String; overload;
    function Get(const AResource: String; AToken: String; out AJSONResult: String): iEvolutionApi<T>;
    function Send(const AResource: String; AJSON: String; AToken: String; out AJSONResult: String): iEvolutionApi<T>; overload;
    function Send(const AResource: String; AJSON: String; AToken: String): iEvolutionApi<T>; overload;
    function &End : T;
  end;
  TEvolutionApi<T: IInterface> = class(TInterfacedObject, iEvolutionApi<T>)
  private
    [Weak]
    FParent: T;
    FUrl, FInstancia, FToken, FMensagem: String;
    FSucesso: Boolean;
  public
    constructor Create(Parent: T);
    destructor Destroy; override;
    class function New(Parent: T): iEvolutionApi<T>;
    function &End : T;
    function Url(AValue: String): iEvolutionApi<T>; overload;
    function Url: String; overload;
    function Instancia(AValue: String): iEvolutionApi<T>; overload;
    function Instancia: String; overload;
    function Token(AValue: String): iEvolutionApi<T>; overload;
    function Token: String; overload;
    function Get(const AResource: String; AToken: String; out AJSONResult: String): iEvolutionApi<T>;
    function Send(const AResource: String; AJSON: String; AToken: String; out AJSONResult: String): iEvolutionApi<T>; overload;
    function Send(const AResource: String; AJSON: String; AToken: String): iEvolutionApi<T>; overload;
  end;

  iEvolution = interface
    ['{1EDD7045-3348-48AE-AB6A-AA936890B42C}']
    function EvolutionApi: iEvolutionApi<iEvolution>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function EnviaMsg(ATelefone, AMsg: String): iEvolution;
    function EnviaPdf(ATelefone, AMsg, AFileName, AMedia: String): iEvolution;

    function Status: boolean;
    function QrCode(ATelefone: String): String;
    function Logout: boolean;
    function Delete: boolean;
  end;
  TEvolution = class(TInterfacedObject, iEvolution)
    private
      FEvolutionApi: iEvolutionApi<iEvolution>;
      FSucesso: Boolean;
      FMensagem: String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
      function GenDelayMsg: integer;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEvolution;
      function EvolutionApi: iEvolutionApi<iEvolution>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function EnviaMsg(ATelefone, AMsg: String): iEvolution;
      function EnviaPdf(ATelefone, AMsg, AFileName, AMedia: String): iEvolution;

      function Status: boolean;
      function QrCode(ATelefone: String): String;
      function Logout: boolean;
      function Delete: boolean;
  end;

implementation

{ TEvolutionApi<T> }

class function TEvolutionApi<T>.New(Parent: T): iEvolutionApi<T>;
begin
  Result:= Self.Create(Parent);
end;

constructor TEvolutionApi<T>.Create(Parent: T);
begin
  FParent:= Parent;
  FSucesso:= False;
  FMensagem:= '';
end;

destructor TEvolutionApi<T>.Destroy;
begin
  inherited;
end;

function TEvolutionApi<T>.&End: T;
begin
  Result:= FParent;
end;

function TEvolutionApi<T>.Token(AValue: string): iEvolutionApi<T>;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TEvolutionApi<T>.Token: String;
begin
  Result:= FToken;
end;

function TEvolutionApi<T>.Url: String;
begin
  Result:= FUrl;
end;

function TEvolutionApi<T>.Url(AValue: String): iEvolutionApi<T>;
begin
  Result:= Self;
  FUrl:= AValue;
end;

function TEvolutionApi<T>.Instancia(AValue: string): iEvolutionApi<T>;
begin
  Result:= Self;
  FInstancia:= AValue;
end;

function TEvolutionApi<T>.Instancia: String;
begin
  Result:= FInstancia;
end;

function TEvolutionApi<T>.Get(const AResource: String; AToken: String; out AJSONResult: String): iEvolutionApi<T>;
var
  vResp: IResponse;
  vJSONResp: TJSONObject;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AddHeader('apikey', FToken)
          .AcceptEncoding('UTF-8')
          .Get;
    if not (vResp.StatusCode = 200) then begin
      vJSONResp:= TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes(vResp.Content), 0) as TJSONObject;
      if vJSONResp <> nil then begin
        try
          raise Exception.Create(vJSONResp.GetValue<String>('error'));
        finally
          vJSONResp.Free;
        end;
      end;
    end;
    AJSONResult:= vResp.Content;
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

function TEvolutionApi<T>.Send(const AResource: String; AJSON: String; AToken: String): iEvolutionApi<T>;
var
  vResp: IResponse;
  vJSONResp: TJSONObject;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AddHeader('apikey', AToken)
          .AcceptEncoding('gzip, deflate, br')
          .AddBody(AJSON)
          .Post;
    if not (vResp.StatusCode = 201) then begin
      vJSONResp:= TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes(vResp.Content), 0) as TJSONObject;
      if vJSONResp <> nil then begin
        try
          var vJsonResponse: TJSONObject:= vJSONResp.GetValue<TJSONObject>('response');
          raise Exception.Create(vJsonResponse.GetValue<String>('message'));
        finally
          vJSONResp.Free;
        end;
      end;
    end;
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

function TEvolutionApi<T>.Send(const AResource: String; AJSON: String; AToken: String; out AJSONResult: String): iEvolutionApi<T>;
var
  vResp: IResponse;
  vJSONResp: iJsonVal;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
          .Timeout(C_TIMEOUT)
          .Resource(AResource)
          .ContentType('application/json')
          .AddHeader('apikey', AToken)
          .AcceptEncoding('gzip, deflate, br')
          .AddBody(AJSON)
          .Post;
    if not (vResp.StatusCode = 201) then begin
      vJSONResp:= TJsonVal.New(vResp.Content);
//      raise Exception.Create(vJSONResp.GetValueAsString('Erro'));
    end else
      AJSONResult:= vResp.Content;
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

{ TEvolutionApi }

class function TEvolution.New: iEvolution;
begin
  Result:= Self.Create;
end;

constructor TEvolution.Create;
begin
  FEvolutionApi:= TEvolutionApi<iEvolution>.New(Self);
end;

destructor TEvolution.Destroy;
begin

  inherited;
end;

function TEvolution.QrCode(ATelefone: String): String;
var
  vJsonObj: iJsonObj;
  vJSONResp, vJsonInstance, vJsonQrCode, vJsonHash: TJSONObject;
  vJSONResult: string;
begin
  vJsonObj:= TJsonObj.New;
  try
    vJsonObj.AddPair('instanceName', FEvolutionApi.Instancia);
    vJsonObj.AddPair('token', '');
    vJsonObj.AddPair('qrcode', true);
    vJsonObj.AddPair('number', '55' + ATelefone);
    FEvolutionApi.Send('instance/create', vJsonObj.ToString, FEvolutionApi.Token, vJSONResult);

    vJSONResp:= TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes(vJSONResult), 0) as TJSONObject;
    if vJSONResp <> nil then begin
      try
        vJsonInstance:= vJSONResp.GetValue<TJSONObject>('instance');
        if vJsonInstance.GetValue<String>('status').Equals('created') then begin
          vJsonQrCode:= vJSONResp.GetValue<TJSONObject>('qrcode');
          Result:= vJsonQrCode.GetValue<String>('base64');
          vJsonHash:= vJSONResp.GetValue<TJSONObject>('hash');
          FEvolutionApi.Token(vJsonHash.GetValue<String>('apikey'));
          SetReqResult(True, 'Conectado');
        end else
          raise Exception.Create('Erro ao conectar');
      finally
        vJSONResp.Free;
      end;
    end;
  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TEvolution.Delete: boolean;
var
  vResp: IResponse;
begin
  Result:= False;
  try
    vResp:= TRequest.New.BaseURL(FEvolutionApi.Url)
          .Timeout(C_TIMEOUT)
          .Resource('instance/delete/' + FEvolutionApi.Instancia)
          .ContentType('application/json')
          .AddHeader('apikey', FEvolutionApi.Token)
          .AcceptEncoding('gzip, deflate, br')
          .Delete;
    if not (vResp.StatusCode = 200) then begin
      raise Exception.Create('Erro ao deletar instância');
    end;
    Result:= True;
  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TEvolution.Status: boolean;
var
  vJSONResp, vJsonInstance: TJSONObject;
  vJSONResult, vState: string;
begin
  Result:= False;
  if FEvolutionApi.Instancia = '' then
    Exit;
  try
    FEvolutionApi.Get('instance/connectionState/' + FEvolutionApi.Instancia, FEvolutionApi.Token, vJSONResult);
    vJSONResp:= TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes(vJSONResult), 0) as TJSONObject;
    if vJSONResp <> nil then begin
      try
        vJsonInstance:= vJSONResp.GetValue<TJSONObject>('instance');
        if vJsonInstance.TryGetValue('state', vState) then
          Result:= vState.Equals('open');
      finally
        vJSONResp.Free;
      end;
    end;
  except
//    on E:Exception do
//      raise Exception.Create('Erro:' + #13#10 + E.Message);
  end;
end;

function TEvolution.Logout: boolean;
var
  vResp: IResponse;
begin
  Result:= False;
  try
    vResp:= TRequest.New.BaseURL(FEvolutionApi.Url)
          .Timeout(C_TIMEOUT)
          .Resource('instance/logout/' + FEvolutionApi.Instancia)
          .ContentType('application/json')
          .AddHeader('apikey', FEvolutionApi.Token)
          .AcceptEncoding('gzip, deflate, br')
          .Delete;
    if not (vResp.StatusCode = 200) then begin
      raise Exception.Create('Erro ao fazer logout: ' + vResp.Content);
    end;
    Result:= True;
  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TEvolution.EnviaMsg(ATelefone, AMsg: String): iEvolution;
var
  vJsonPrincipal, vJsonOptions, vJsonTxtMsg: TJSONObject;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vJsonPrincipal:= TJSONObject.Create;
  try
    vJsonPrincipal.AddPair('number', '55' + ATelefone);
    vJsonPrincipal.AddPair('token', '');

    vJsonOptions:= TJSONObject.Create;
    vJsonOptions.AddPair('delay', TJSONNumber.Create(TLib.GetRandomNumber(1200, 15000)));
    vJsonOptions.AddPair('presence', TJSONString.Create('composing'));
    vJsonOptions.AddPair('linkPreview', TJSONBool.Create(false));
    vJsonPrincipal.AddPair('options', vJsonOptions);

    AMsg:= StringReplace(AMsg, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);

    vJsonTxtMsg:= TJSONObject.Create;
    vJsonTxtMsg.AddPair('text', TJSONString.Create(AMsg));

    vJsonPrincipal.AddPair('textMessage', vJsonTxtMsg);

    try
      FEvolutionApi.Send('message/sendText/' + FEvolutionApi.Instancia, vJsonPrincipal.ToString, FEvolutionApi.Token);
      SetReqResult(True, 'Enviado com sucesso');
    except
      on E:Exception do
        SetReqResult(False, 'Erro ao enviar a mensagem:' + #13#10 + E.Message);
    end;
  finally
    vJsonPrincipal.Free;
  end;
end;

function TEvolution.EnviaPdf(ATelefone, AMsg, AFileName, AMedia: String): iEvolution;
var
  vJsonPrincipal, vJsonOptions, vJsonTxtMsg: TJSONObject;
begin
  Result:= Self;
  ATelefone:= TLib.SomenteNumero(ATelefone);
  vJsonPrincipal:= TJSONObject.Create;
  try
    vJsonPrincipal.AddPair('number', '55' + ATelefone);
    vJsonPrincipal.AddPair('token', '');

    vJsonOptions:= TJSONObject.Create;
    vJsonOptions.AddPair('delay', TJSONNumber.Create(TLib.GetRandomNumber(1200, 15000)));
    vJsonOptions.AddPair('presence', TJSONString.Create('composing'));
    vJsonPrincipal.AddPair('options', vJsonOptions);

    AMsg:= StringReplace(AMsg, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);

    vJsonTxtMsg:= TJSONObject.Create;
    vJsonTxtMsg.AddPair('mediatype', TJSONString.Create('document'));
    vJsonTxtMsg.AddPair('fileName', TJSONString.Create(AFileName));
    vJsonTxtMsg.AddPair('caption', TJSONString.Create(AMsg));
    vJsonTxtMsg.AddPair('media', TJSONString.Create(AMedia));

    vJsonPrincipal.AddPair('mediaMessage', vJsonTxtMsg);

    try
      FEvolutionApi.Send('message/sendMedia/' + FEvolutionApi.Instancia, vJsonPrincipal.ToString, FEvolutionApi.Token);
      SetReqResult(True, 'Enviado com sucesso');
    except
      on E:Exception do
        SetReqResult(False, 'Erro ao enviar o documento:' + #13#10 + E.Message);
    end;
  finally
    vJsonPrincipal.Free;
  end;
end;

function TEvolution.EvolutionApi: iEvolutionApi<iEvolution>;
begin
  Result:= FEvolutionApi;
end;

procedure TEvolution.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMensagem:= AMensagem;
end;

function TEvolution.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

function TEvolution.Mensagem: String;
begin
  Result:= FMensagem;
end;

function TEvolution.GenDelayMsg: integer;
begin

end;

end.
