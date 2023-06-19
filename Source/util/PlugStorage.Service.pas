unit PlugStorage.Service;

interface

uses
  System.Classes, System.SysUtils, System.JSON, RESTRequest4D, Xml.Reader, Byte.Json;

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
    function GetDestinadas(ADtInicio, ADtFim: TDateTime; AModDoc: String = 'NFE'): String;
    function ConfigDestinadas(AFilePath: String): iPlugStorage;

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
      function GetDestinadas(ADtInicio, ADtFim: TDateTime; AModDoc: String = 'NFE'): String;
      function ConfigDestinadas(AFilePath: String): iPlugStorage;
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
              .Resource('invoices/export?token='+ FToken + '&invoice_key=' + FChaveXml + '&mode=XML&downloaded=true&xml=XML')
              .Accept('application/xml')
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FUsuario, FSenha)
              .Get;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        vSucesso:= not vSucesso;

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
  vPosTagInicio, vPosTagFim: integer;
  vDataRecbto, vDataRecbtoNew: string;
begin
  Result:= Self;
  try
    vPosTagInicio:= Pos('<dhRecbto>', FXml) + 10;
    vDataRecbto:= Copy(FXml, vPosTagInicio, FXml.Length - vPosTagInicio);
    vPosTagFim:= Pos('</dhRecbto>', vDataRecbto) - 1;
    vDataRecbto:= Copy(vDataRecbto, 1, vPosTagFim);
    if vDataRecbto.Contains('+') then begin
      vDataRecbtoNew:= Copy(vDataRecbto, 1, Pos('+', vDataRecbto) - 1);
      FXml:= StringReplace(FXml, vDataRecbto, vDataRecbtoNew, [rfReplaceAll, rfIgnoreCase]);
    end;



    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('invoices?token=' + FToken)
              .Accept('application/xml')
              .ContentType('application/x-www-form-urlencoded')
              .AcceptEncoding('gzip, deflate, br')
              .AcceptCharset('UTF-8')
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

function TPlugStorage.GetDestinadas(ADtInicio, ADtFim: TDateTime; AModDoc: String): String;
var
  vResp: IResponse;
  vJsonContent, vJsonData: iJsonVal;
  vInvoices: iJsonArr;
  vSucesso: boolean;
  vResource, vData, vLastID: String;
  vCount, vTotal, vQtddReq: integer;
begin
  Result:= '';
  vLastID:= '';
  vResource:= 'invoices/keys?token=' + FToken + '&date_ini=' + FormatDateTime('yyyy-mm-dd', ADtInicio) + '&date_end=' + FormatDateTime('yyyy-mm-dd', ADtFim)
                + '&mod=' + AModDoc + '&transaction=received&limit=30&last_id=';

  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource(vResource)
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FUsuario, FSenha)
              .Get;

    if not vResp.Content.IsEmpty then begin
      vJsonContent:= TJsonVal.New(vResp.Content);
      var vStr: string := vResp.Content;
      vJsonContent.GetValue('error', vSucesso);
      vSucesso:= not vSucesso;

      if not vSucesso then
        raise Exception.Create(vJsonContent.GetValueAsString('message'));

      SetReqResult(vSucesso, vJsonContent.GetValueAsString('message'));

      vJsonContent.GetValue('count', vCount);
      vJsonContent.GetValue('total', vTotal);

      if vCount = 0 then
        Exit;

      vData:= vJsonContent.GetValueAsString('data');

      vJsonData:= TJsonVal.New(vData);
      vInvoices:= TJsonArr.New;
      vInvoices.Add(vJsonData.GetValueAsString('invoices'));

      vQtddReq:= (vTotal div vCount) - 1;

      for var I := 1 to vQtddReq do begin
        vLastID:= vJsonContent.GetValueAsString('last_id');

        vResp:= TRequest.New.BaseURL(FUrl)
                  .Timeout(FTimeout)
                  .Resource(vResource + vLastID)
                  .ContentType('application/x-www-form-urlencoded')
                  .BasicAuthentication(FUsuario, FSenha)
                  .Get;

        if not vResp.Content.IsEmpty then begin
          vJsonContent:= TJsonVal.New(vResp.Content);
          vJsonContent.GetValue('error', vSucesso);
          vSucesso:= not vSucesso;

          if not vSucesso then
            raise Exception.Create(vJsonContent.GetValueAsString('message'));

          vJsonContent.GetValue('count', vCount);
          vJsonContent.GetValue('total', vTotal);

          SetReqResult(vSucesso, vJsonContent.GetValueAsString('message'));

          vData:= vJsonContent.GetValueAsString('data');
          vInvoices.Add(vJsonData.GetValueAsString('invoices'));
        end;
      end;

      Result:= vInvoices.AsString;
    end;

  except
    on E:Exception do
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.ConfigDestinadas(AFilePath: String): iPlugStorage;
var
  vResp: IResponse;
  vStream: TMemoryStream;
  vResource: String;
  vSucesso: boolean;
  vJsonContent: iJsonVal;
  vJson: String;
begin
  Result:= Self;

  vResource:= 'destinadas/configdestined?token=' + FToken;

  vStream:= TMemoryStream.Create;
  vStream.LoadFromFile(AFilePath);
  vJson:= MontaBodyReq(FJson);
  try

    try
      vResp:= TRequest.New.BaseURL(FUrl)
                .Timeout(FTimeout)
                .Resource(vResource)
                .ContentType('multipart/form-data')
                .BasicAuthentication(FUsuario, FSenha)
                .AddFile('cert_pfx', vStream)
                .AddBody(vJson)
                .Post;

      if not vResp.Content.IsEmpty then begin
        vJsonContent:= TJsonVal.New(vResp.Content);
        vJsonContent.GetValue('error', vSucesso);
        vSucesso:= not vSucesso;

        if not vSucesso then
          raise Exception.Create(vJsonContent.GetValueAsString('message'));

        SetReqResult(vSucesso, vJsonContent.GetValueAsString('message'));
      end;
    except
      on E:Exception do
        SetReqResult(False, E.Message);
    end;
  finally
    vStream.Free;
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
