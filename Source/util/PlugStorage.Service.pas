unit PlugStorage.Service;

interface

uses
  System.Classes, System.SysUtils, System.JSON, RESTRequest4D, Xml.Reader, Byte.Json,
  Controller.Factory.Table, Model.Conexao.Interfaces, Data.DB;

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
    function GetDestinadas(ADtInicio, ADtFim: TDateTime; AModDoc: String = 'NFE'): iPlugStorage;
    function ValidaCertificado(ACnpj: String): iPlugStorage;
    function ConfigDestinadas: iPlugStorage;
    function ContadorVinculado(ACnpj: String): Boolean;

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
    function Table(ATable: iTable): iPlugStorage;
    function Certificado_Path(AValue: String): iPlugStorage;
    function Certificado_Password(AValue: String): iPlugStorage;

    function GetResult: Boolean;
    function GetMensagem: String;

    property Sucesso: Boolean read GetResult;
    property Mensagem: String read GetMensagem;
  end;

  TPlugStorage = class(TInterfacedObject, iPlugStorage)
    protected
    private
      FJson: TJSONValue;
      FTable: iTable;
      FUsuario, FSenha, FXml, FChaveXml, FToken, FUrl, FCertificado_Path, FCertificado_Password: string;
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
      function GetDestinadas(ADtInicio, ADtFim: TDateTime; AModDoc: String = 'NFE'): iPlugStorage;
      function ValidaCertificado(ACnpj: String): iPlugStorage;
      function ConfigDestinadas: iPlugStorage;
      function ContadorVinculado(ACnpj: String): Boolean;
      function Usuario(AUsuario: String): iPlugStorage;
      function Senha(ASenha: String): iPlugStorage;
      function XML(AXml: String): iPlugStorage; overload;
      function XML: String; overload;
      function Json(AJson: String): iPlugStorage;
      function ChaveXml(AChaveXml: String): iPlugStorage;
      function URL(AValue: String): iPlugStorage;
      function Token(AValue: String): iPlugStorage;
      function Timeout(AValue: integer): iPlugStorage;
      function Table(ATable: iTable): iPlugStorage;
      function Certificado_Path(AValue: String): iPlugStorage;
      function Certificado_Password(AValue: String): iPlugStorage;

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
              .Resource('invoices/export?token='+ FToken + '&invoice_key=' + FChaveXml + '&mode=XML&downloaded=true&xml=XML&resume=false')
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
  //EM DESUSO APÓS ATUALIZAÇÃO DO DELPHI E RESTREQUEST4D
//    vPosTagInicio:= Pos('<dhRecbto>', FXml) + 10;
//    vDataRecbto:= Copy(FXml, vPosTagInicio, FXml.Length - vPosTagInicio);
//    vPosTagFim:= Pos('</dhRecbto>', vDataRecbto) - 1;
//    vDataRecbto:= Copy(vDataRecbto, 1, vPosTagFim);
//    if vDataRecbto.Contains('+') then begin
//      vDataRecbtoNew:= Copy(vDataRecbto, 1, Pos('+', vDataRecbto) - 1);
//      FXml:= StringReplace(FXml, vDataRecbto, vDataRecbtoNew, [rfReplaceAll, rfIgnoreCase]);
//    end;

    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('invoices?token=' + FToken)
              .Accept('application/xml')
              .ContentType('application/x-www-form-urlencoded')
              .AcceptEncoding('gzip, deflate, br')
              .AcceptCharset('UTF-8')
              .BasicAuthentication(FUsuario, FSenha)
              .AddField('xml', FXml)
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

function TPlugStorage.ValidaCertificado(ACnpj: String): iPlugStorage;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('https://app.plugstorage.com.br/api/clients/certificate?cnpj_cpf=' + ACnpj)
              .Accept('application/json')
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FToken, FSenha)
              .Post;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        vSucesso:= not vSucesso;
        SetReqResult(vSucesso, vJsonResp.GetValue<String>('message'))
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

function TPlugStorage.GetDestinadas(ADtInicio, ADtFim: TDateTime; AModDoc: String): iPlugStorage;
  function Requisicao(ADtInicio, ADtFim: TDateTime; AModDoc: String; ALastID: String = ''): String;
  var
    vResp: IResponse;
    vResource: String;
  begin
    Result:= '';
    vResource:= 'invoices/keys?token=' + FToken + '&date_ini=' + FormatDateTime('yyyy-mm-dd', ADtInicio) + '&date_end=' + FormatDateTime('yyyy-mm-dd', ADtFim)
                + '&mod=' + AModDoc + '&transaction=received&limit=30&last_id=';
    if not ALastID.IsEmpty then
      vResource:= vResource + ALastID;
    try
      vResp:= TRequest.New.BaseURL(FUrl)
                .Timeout(FTimeout)
                .Resource(vResource)
                .ContentType('application/x-www-form-urlencoded')
                .BasicAuthentication(FUsuario, FSenha)
                .Get;
      Result:= vResp.Content;
    except
    end;
  end;
  
  procedure GeraTableDestinadas(ATable: iTable);
  begin
    ATable.Tabela.FieldDefs.Add('XML_CHAVE', ftString, 100);
    ATable.Tabela.FieldDefs.Add('EMITENTE_CNPJ', ftString, 20);
    ATable.Tabela.FieldDefs.Add('EMITENTE_RAZAOSOCIAL', ftString, 100);
    ATable.Tabela.FieldDefs.Add('EMITENTE_FANTASIA', ftString, 100);
    ATable.Tabela.FieldDefs.Add('EMISSAO', ftDateTime);
    ATable.Tabela.FieldDefs.Add('VALOR', ftFloat);
    ATable.Tabela.FieldDefs.Add('LANCADA', ftBoolean);
    ATable.CriaDataSet;
  end;

  procedure PopulaTableDestinadas(ATable: iTable; AArray: TJSONArray);
  var
    vJsonObjInvoice: TJSONObject;
    vArrayCount: integer;
    vFormatSet: TFormatSettings;
    vValor: String;
  begin
    vFormatSet.ShortDateFormat:= 'yyyy-mm-dd';
    vFormatSet.DateSeparator:= '-';

    for vArrayCount := 0 to AArray.Size - 1 do begin
      vjsonObjInvoice:= AArray.Get(vArrayCount) as TJSONObject;
      ATable.Tabela.Append;
      ATable.Tabela.FieldByName('XML_CHAVE').AsString:= vjsonObjInvoice.Get('key').JsonValue.Value;
      ATable.Tabela.FieldByName('EMITENTE_CNPJ').AsString:= vjsonObjInvoice.Get('cnpj_emitter').JsonValue.Value;
      ATable.Tabela.FieldByName('EMITENTE_RAZAOSOCIAL').AsString:= vjsonObjInvoice.Get('razao_social').JsonValue.Value;
      ATable.Tabela.FieldByName('EMITENTE_FANTASIA').AsString:= vjsonObjInvoice.Get('fantasia').JsonValue.Value;
      ATable.Tabela.FieldByName('EMISSAO').AsDateTime:= StrtoDate(vjsonObjInvoice.Get('date_emission').JsonValue.Value, vFormatSet);
      vValor:= StringReplace(vjsonObjInvoice.Get('value').JsonValue.Value, '.', ',', [rfReplaceAll, rfIgnoreCase]);
      ATable.Tabela.FieldByName('VALOR').AsString:= vValor;
      ATable.Tabela.FieldByName('LANCADA').AsBoolean:= False;
      ATable.Tabela.Post;
    end;
  end;

  function GetNotas(ADados: String; ATable: iTable; out ALastID: String): Integer;
  var
    vJsonObj, vJsonObjData: TJSONObject;
    vJsonArrayInvoices: TJSONArray;
    vSucesso: boolean;
    vMsg: String;
    vCount, vTotal, vReqCount: integer;
  begin
    Result:= 0;
    vJsonObj:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ADados), 0) as TJSONObject;
    try
      vJsonObjData:= vJsonObj.Get('data').JsonValue as TJSONObject;
      vSucesso:= vJsonObj.GetValue<boolean>('error');
      vSucesso:= not vSucesso;
      vMsg:= vJsonObj.GetValue<String>('message');
      if not vSucesso then
        raise Exception.Create(vMsg);
        
      vCount:= vJsonObjData.GetValue<integer>('count');
      vTotal:= vJsonObjData.GetValue<integer>('total');

      if vCount = 0 then
        Exit;

      vJsonArrayInvoices:= vJsonObjData.Get('invoices').JsonValue as TJSONArray;
      PopulaTableDestinadas(ATable, vJsonArrayInvoices);

      Result:= (vTotal div vCount) - 1;
      vJsonObjData.TryGetValue<String>('last_id', ALastID);  

      SetReqResult(vSucesso, vMsg);  
    finally
      FreeAndNil(vJsonObj);
    end;
  end;
var
  vJsonDados, vLastID: String;
  vQtddReq, vReqCount: integer;
begin
  Result:= Self;
  vReqCount:= 0;
  try
    GeraTableDestinadas(FTable);

    vJsonDados:= Requisicao(ADtInicio, ADtFim, AModDoc);
    if not vJsonDados.IsEmpty then begin
      vQtddReq:= GetNotas(vJsonDados, FTable, vLastID);
      
      while vReqCount < vQtddReq do begin
        vJsonDados:= Requisicao(ADtInicio, ADtFim, AModDoc, vLastID);
        if not vJsonDados.IsEmpty then
          vQtddReq:= GetNotas(vJsonDados, FTable, vLastID);
      end;
    end else
      SetReqResult(False, 'Erro ao obter as notas.');
  except
    on E:Exception do 
      SetReqResult(False, E.Message);
  end;
end;

function TPlugStorage.ConfigDestinadas: iPlugStorage;
var
  vResp: IResponse;
  vResource: String;
  vSucesso: boolean;
  vJsonContent: iJsonVal;
begin
  Result:= Self;

  vResource:= 'destinadas/configdestined?token=' + FToken;

  try
    if FCertificado_Password = '' then
      raise Exception.Create('É obrigatório informar a senha.');

    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource(vResource)
              .BasicAuthentication(FUsuario, FSenha)
              .AddFile('cert_pfx', FCertificado_Path)
              .AddField('cert_password', FCertificado_Password)
              .AddField('dfe_cert_concentrating', '0')
              .AddField('uf', 'SP')
              .AddField('dfe_period', '2')
              .AddField('dfe_tipo', 'NFE')
              .AddField('dfe_notifica', '0')
              .AddField('dfe_cienciaAutomatica', '1')
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
end;

function TPlugStorage.ContadorVinculado(ACnpj: String): Boolean;
var
  vResp: IResponse;
  vJsonResp: TJSONValue;
  vSucesso: boolean;
  vVinculado: String;
begin
  Result:= False;

  try
    vResp:= TRequest.New.BaseURL(FUrl)
              .Timeout(FTimeout)
              .Resource('clients/accountant?cnpj_cpf=' + ACnpj)
              .ContentType('application/x-www-form-urlencoded')
              .BasicAuthentication(FToken, FSenha)
              .Get;

    if not vResp.Content.IsEmpty then begin
      vJsonResp:= TJSONObject.ParseJSONValue(vResp.Content);
      try
        vJsonResp.TryGetValue<Boolean>('error', vSucesso);
        vSucesso:= not vSucesso;
        SetReqResult(vSucesso, vJsonResp.GetValue<String>('message'));
        if vSucesso then begin
          vJsonResp.TryGetValue<String>('confirmation', vVinculado);
          Result:= vVinculado.Equals('CONFIRMADO');
        end;
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

function TPlugStorage.Table(ATable: iTable): iPlugStorage;
begin
  Result:= Self;
  if Assigned(ATable) then
    FTable:= ATable;
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

function TPlugStorage.Certificado_Password(AValue: String): iPlugStorage;
begin
  Result:= Self;
  FCertificado_Password:= AValue;
end;

function TPlugStorage.Certificado_Path(AValue: String): iPlugStorage;
begin
  Result:= Self;
  FCertificado_Path:= AValue;
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
