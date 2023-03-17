unit PlugStorage.Service;

interface

uses
  System.Classes, System.SysUtils, System.JSON, RESTRequest4D, Xml.Reader;

type

  iPlugStorage = interface
    ['{15ABE1B5-ABDB-4D23-A71A-E891F2DC817D}']
    //Rotas
    function PostUsuario: iPlugStorage;
    function PutUsuario: iPlugStorage;
    function PostXML: iPlugStorage;
    function GetXML: iPlugStorage;
    function UpdateEmailCliente: iPlugStorage;
    function VinculaContadorCliente: iPlugStorage;
    function DesvinculaContador: iPlugStorage;
    function VinculaGrupo(AId: String): iPlugStorage;
    function CriaGrupo(out AId: String): iPlugStorage;

    //Parametros
    function URL(AValue: String): iPlugStorage;
    function Token(AValue: String): iPlugStorage;
    function Timeout(AValue: integer): iPlugStorage;
    function Usuario(AUsuario: String): iPlugStorage;
    function Senha(ASenha: String): iPlugStorage;
    function XML(AXml: String): iPlugStorage; overload;
    function XML: String; overload;
    function Json(AJson: String): iPlugStorage;
    function ChaveXml(AChaveXml: String): iPlugStorage;

    function GetResult: Boolean;
    function GetMensagem: String;

    property Sucesso: Boolean read GetResult;
    property Mensagem: String read GetMensagem;
  end;

  TPlugStorage = class(TInterfacedObject, iPlugStorage)
    protected
    private
      FJson: TJSONValue;
      FUsuario, FSenha, FXml, FChaveXml, FToken, FUrl: string;
      FSucesso: Boolean;
      FMensagem: String;
      FTimeout: integer;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
      function GetResult: Boolean;
      function GetMensagem: String;

      function MontaBodyReq(AJSONValue: TJSONValue): String;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iPlugStorage;
      function PostUsuario: iPlugStorage;
      function PutUsuario: iPlugStorage;
      function PostXML: iPlugStorage;
      function GetXML: iPlugStorage;
      function UpdateEmailCliente: iPlugStorage;
      function VinculaContadorCliente: iPlugStorage;
      function DesvinculaContador: iPlugStorage;
      function VinculaGrupo(AId: String): iPlugStorage;
      function CriaGrupo(out AId: String): iPlugStorage;
      function Usuario(AUsuario: String): iPlugStorage;
      function Senha(ASenha: String): iPlugStorage;
      function XML(AXml: String): iPlugStorage; overload;
      function XML: String; overload;
      function Json(AJson: String): iPlugStorage;
      function ChaveXml(AChaveXml: String): iPlugStorage;
      function URL(AValue: String): iPlugStorage;
      function Token(AValue: String): iPlugStorage;
      function Timeout(AValue: integer): iPlugStorage;

      property Sucesso: Boolean read GetResult;
      property Mensagem: String read GetMensagem;
  end;

implementation

{ TPlugStorage }

class function TPlugStorage.New: iPlugStorage;
begin
  Result:= Self.Create;
end;

constructor TPlugStorage.Create;
begin
  FSucesso:= False;
  FMensagem:= EmptyStr;
end;

destructor TPlugStorage.Destroy;
begin
  if Assigned(FJson) then
    FJson.Free;
  inherited;
end;

{$REGION 'ROTAS'}
function TPlugStorage.PostUsuario: iPlugStorage;
var
  vResp: IResponse;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('users/?softwarehouse=' + FToken)
              .Accept('application/xml')
              .ContentType('application/x-www-form-urlencoded')
              .AddBody(MontaBodyReq(FJson))
              .Post;

    SetReqResult((vResp.StatusCode = 200) or (vResp.StatusCode = 201), vResp.Content);
  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.PutUsuario: iPlugStorage;
var
  vResp: IResponse;
  vCpfCnpjKeyValue, vCpfCnpjKeyName: string;
begin
  Result:= Self;
  try
    if FJson.TryGetValue<string>('cnpj', vCpfCnpjKeyValue) then
      vCpfCnpjKeyName:= 'cnpj'
    else if FJson.TryGetValue<string>('cpf', vCpfCnpjKeyValue) then
      vCpfCnpjKeyName:= 'cpf';


    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('users/?softwarehouse=' + FToken + '&' + vCpfCnpjKeyName + '=' + vCpfCnpjKeyValue)
              .Accept('application/json')
              .ContentType('application/x-www-form-urlencoded')
              .AddBody(MontaBodyReq(FJson))
              .Put;

    SetReqResult((vResp.StatusCode = 200) or (vResp.StatusCode = 201), vResp.Content);
  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.GetXML: iPlugStorage;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;
  try
    if (FUsuario.IsEmpty) or (FSenha.IsEmpty) then
      raise Exception.Create('Usuario e senha não podem estar vazios');

    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('invoices/invoices/export?token='+ FToken + '&invoice_key=' + FChaveXml + '&mode=XML&xml=XML')
              .Accept('application/xml')
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FUsuario, FSenha)
              .Get;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        if vSucesso then
          FXml:= vJsonResp.GetValue<string>('data.xml');

        SetReqResult(vSucesso, vJsonResp.GetValue<string>('message'));
      finally
        vJsonResp.Free;
      end;
    end else
      raise Exception.Create('Erro ao receber o XML da API');

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.PostXML: iPlugStorage;
var
  vResp: IResponse;
  vXMLReader: IXMLReader;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('invoices?token=' + FToken)
              .Accept('application/xml')
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FUsuario, FSenha)
              .AddBody('xml=' + FXml)
              .Post;

    vXMLReader:= TXmlReader.New.LoadFromString(vResp.Content);

    SetReqResult((vResp.StatusCode = 200) or (vResp.StatusCode = 201), vXMLReader.Node.GetElement('message').AsString);
  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.UpdateEmailCliente: iPlugStorage;
var
  vResp: IResponse;
  vCurrentEmail, vNewEmail: String;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;
  try
    vCurrentEmail:= FJson.GetValue<string>('current_email');
    vNewEmail:= FJson.GetValue<string>('new_email');

    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('clients/updateemail')
              .Accept('application/json')
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FUsuario, FSenha)
              .AddParam('current_email', vCurrentEmail)
              .AddParam('new_email', vNewEmail)
              .Post;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        if vJsonResp.TryGetValue<Boolean>('error', vSucesso) then
          SetReqResult(False, vJsonResp.GetValue<String>('message'))
        else
          SetReqResult(True, vJsonResp.GetValue<String>('message'));
      finally
        vJsonResp.Free;
      end;
    end;

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.VinculaContadorCliente: iPlugStorage;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('users/linkaccountant?token=' + FToken)
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FUsuario, FSenha)
              .AddBody(MontaBodyReq(FJson))
              .Post;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        if vJsonResp.TryGetValue<Boolean>('error', vSucesso) then
          SetReqResult(False, vJsonResp.GetValue<String>('message'))
        else
          SetReqResult(True, vJsonResp.GetValue<String>('message'));
      finally
        vJsonResp.Free;
      end;
    end;

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.DesvinculaContador: iPlugStorage;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('clients/unlinkaccountant')
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FToken, FSenha)
              .AddBody(MontaBodyReq(FJson))
              .Post;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        vSucesso:= not vSucesso;
        SetReqResult(vSucesso, vJsonResp.GetValue<String>('message'));
      finally
        vJsonResp.Free;
      end;
    end;

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.VinculaGrupo(AId: String): iPlugStorage;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;

  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('groups/vinculumgroup?softwarehouse_token=' + FToken + '&group_id=' + AId)
              .ContentType('application/x-www-form-urlencoded')
              .AddBody(MontaBodyReq(FJson))
              .Post;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        vSucesso:= not vSucesso;
        vJsonResp.TryGetValue<String>('group_id', AId);
        SetReqResult(vSucesso, vJsonResp.GetValue<String>('message'));
      finally
        vJsonResp.Free;
      end;
    end;

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.CriaGrupo(out AId: String): iPlugStorage;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;

  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('groups?softwarehouse_token=' + FToken)
              .ContentType('application/x-www-form-urlencoded')
              .AddBody(MontaBodyReq(FJson))
              .Post;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        vSucesso:= not vSucesso;
        vJsonResp.TryGetValue<String>('group_id', AId);
        SetReqResult(vSucesso, vJsonResp.GetValue<String>('message'));
      finally
        vJsonResp.Free;
      end;
    end;

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

{$ENDREGION}

{$REGION 'PARAMETROS'}
function TPlugStorage.URL(AValue: String): iPlugStorage;
begin
  Result:= Self;
  FUrl:= AValue;
end;

function TPlugStorage.Timeout(AValue: integer): iPlugStorage;
begin
  Result:= Self;
  FTimeout:= AValue;
end;

function TPlugStorage.Token(AValue: String): iPlugStorage;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TPlugStorage.Senha(ASenha: String): iPlugStorage;
begin
  Result:= Self;
  FSenha:= ASenha;
end;

function TPlugStorage.Usuario(AUsuario: String): iPlugStorage;
begin
  Result:= Self;
  FUsuario:= AUsuario;
end;

function TPlugStorage.XML: String;
begin
  Result:= FXml;
end;

function TPlugStorage.XML(AXml: String): iPlugStorage;
begin
  Result:= Self;
  FXml:= AXml;
end;

function TPlugStorage.Json(AJson: String): iPlugStorage;
begin
  Result:= Self;
  FJson:= TJSONObject.ParseJSONValue(AJson);
end;

function TPlugStorage.ChaveXml(AChaveXml: String): iPlugStorage;
begin
  Result:= Self;
  FChaveXml:= AChaveXml;
end;
{$ENDREGION}

{$REGION 'AUXILIARES'}
procedure TPlugStorage.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMensagem:= AMensagem;
end;

function TPlugStorage.GetMensagem: String;
begin
  Result:= FMensagem;
end;

function TPlugStorage.GetResult: Boolean;
begin
  Result:= FSucesso;
end;

function TPlugStorage.MontaBodyReq(AJSONValue: TJSONValue): String;
var
  vStringReturn: String;
begin
  vStringReturn:= AJSONValue.ToString;
  vStringReturn:= StringReplace(vStringReturn, '{', EmptyStr, [rfReplaceAll, rfIgnoreCase]);
  vStringReturn:= StringReplace(vStringReturn, '}', EmptyStr, [rfReplaceAll, rfIgnoreCase]);
  vStringReturn:= StringReplace(vStringReturn, '"' , EmptyStr, [rfReplaceAll, rfIgnoreCase]);
  vStringReturn:= StringReplace(vStringReturn, ':', '=', [rfReplaceAll, rfIgnoreCase]);
  vStringReturn:= StringReplace(vStringReturn, ',', '&', [rfReplaceAll, rfIgnoreCase]);
  Result:= vStringReturn;
end;

{$ENDREGION}

end.
