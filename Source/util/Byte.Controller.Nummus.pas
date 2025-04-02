unit Byte.Controller.Nummus;
interface
uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.JSON,
  Vcl.StdCtrls,
  Vcl.Controls,
  Byte.Json,
  RESTRequest4D,
  Dataset.Serialize,
  Model.Entidade.Interfaces,
  uCliente,
  Byte.Lib,
  Generics.Collections,
  uEntidade,
  Data.DB,
  Model.Conexao.Interfaces,
  Controller.Factory.Table;
const
  C_TIMEOUT = 120000;
  C_URL = 'https://api.production.nummus.com.br/v1';
type
//  TCustomerData = record
//    Id: string;
//    Name: string;
//    Email: string;
//    Phone: string;
//    BirthDate: TDateTime;
//    Gender: string;
//    DocumentNumber: string;
//    TypeCustomer: string;
//  end;
  TVendaNummus = class
    TicketNumber: string;
    ValueRescue: Double;
    ValueDiscount: Double;
    DescriptionPurchase: string;
  end;
  TProduct = class
    Id: string;
    Name: string;
    Identifier: string;
    ValuePurchase: Double;
  end;
  iNummusBase<T> = interface
    ['{D9A2B355-6B29-4EC9-BE04-CD7B88E470F6}']
    function Sucesso: Boolean; overload;
    procedure Sucesso(AValue: Boolean); overload;
    function Mensagem: String; overload;
    procedure Mensagem(AValue: String); overload;
    function ClientID(AValue: String): iNummusBase<T>; overload;
    function ClientID: String; overload;
    function ApiKey(AValue: String): iNummusBase<T>; overload;
    function ApiKey: String; overload;
    function &End : T;
    function Cliente(AID: Integer): iNummusBase<T>;
    function JsonConsumidor : String;
    function ClienteIdNummus : String;
  end;
  TNummusBase<T: IInterface> = class(TInterfacedObject, iNummusBase<T>)
  private
    [Weak]
    FParent: T;
    FMensagem: String;
    FSucesso: Boolean;
    FApiKey, FClientID, FIDNummus: String;
    FJsonConsumidor: TJSONObject;
    constructor Create(Parent: T);
    destructor Destroy; override;
    function RegistraConsumidor(ADataset: TDataset; ATelefone: String): String;
    procedure SalvaIdNummus(AId: String; ACodigo: integer);
    procedure MontaJsonCliente(ADataset: TDataset; ATelefone: String);
    function ConsultaClientePorDocTel(ACgc, ATelefone: String; ACodCliente: integer): String;
  public
    class function New(Parent: T): iNummusBase<T>;
    function &End : T;
    function Sucesso: Boolean; overload;
    procedure Sucesso(AValue: Boolean); overload;
    function Mensagem: String; overload;
    procedure Mensagem(AValue: String); overload;
    function ClientID(AValue: String): iNummusBase<T>; overload;
    function ClientID: String; overload;
    function ApiKey(AValue: String): iNummusBase<T>; overload;
    function ApiKey: String; overload;
    function Cliente(AID: integer): iNummusBase<T>;
    function JsonConsumidor : String;
    function ClienteIdNummus : String;
  end;
  iNummusCashback = interface
    ['{C7CAF331-391F-4E1A-B510-BE0FB5F6D5A6}']
    function NummusBase: iNummusBase<iNummusCashback>;
    function AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
    function AddVenda(AVenda: TVendaNummus): iNummusBase<iNummusCashback>;
//    function BuscaSaldo(ACodigo: Integer): Currency; overload;
//    function BuscaSaldo(AIDNummus: String): Currency; overload;
    function SimulaResgate(ACodigo: Integer; AValor: Currency): Currency;
    procedure NovoCashback;
    procedure CancelaCashback(AID: String; AMotivo: String);
    procedure BuscaCachbacks(AInicio, AFim: TDate; ACpf: String; AiTable: iTable);
  end;
  TNummusCashback = class(TInterfacedObject, iNummusCashback)
    private
      FNummusBase: iNummusBase<iNummusCashback>;
      FProducts: TObjectList<TProduct>;
      FVenda: TObjectList<TVendaNummus>;
      constructor Create;
      destructor Destroy; override;
      function GeraJson: String;
      procedure PopulaDatasetFromJson(const AJsonStr: string; AiTable: iTable);
      procedure CampoGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    public
      class function New: iNummusCashback;
      function NummusBase: iNummusBase<iNummusCashback>;
      function AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
      function AddVenda(AVenda: TVendaNummus): iNummusBase<iNummusCashback>;
//      function BuscaSaldo(ACodigo: integer): Currency; overload;
//      function BuscaSaldo(AIDNummus: String): Currency; overload;
      function SimulaResgate(ACodigo: integer; AValor: Currency): Currency;
      procedure NovoCashback;
      procedure CancelaCashback(AID: String; AMotivo: String);
      procedure BuscaCachbacks(AInicio, AFim: TDate; ACpf: String; AiTable: iTable);
  end;
implementation

{ TNebulazapBase<T> }

class function TNummusBase<T>.New(Parent: T): iNummusBase<T>;
begin
  Result:= Self.Create(Parent);
end;

constructor TNummusBase<T>.Create(Parent: T);
begin
  FParent:= Parent;
  FMensagem:= '';
end;

destructor TNummusBase<T>.Destroy;
begin
  if Assigned(FJsonConsumidor) then
    FJsonConsumidor.Free;
  inherited;
end;

function TNummusBase<T>.ApiKey(AValue: String): iNummusBase<T>;
begin
  Result:= Self;
  FApiKey:= AValue;
end;

function TNummusBase<T>.ApiKey: String;
begin
  Result:= FApiKey;
end;

function TNummusBase<T>.ClientID(AValue: String): iNummusBase<T>;
begin
  Result:= Self;
  FClientID:= AValue;
end;

function TNummusBase<T>.ClientID: String;
begin
  Result:= FClientID;
end;

function TNummusBase<T>.&End: T;
begin
  Result:= FParent;
end;

function TNummusBase<T>.JsonConsumidor: String;
begin
  Result:= FJsonConsumidor.ToString;
end;

procedure TNummusBase<T>.Mensagem(AValue: String);
begin
  FMensagem:= AValue;
end;

procedure TNummusBase<T>.MontaJsonCliente(ADataset: TDataset; ATelefone: String);
begin
  if Assigned(FJsonConsumidor) then
    FJsonConsumidor.Free;
  FJsonConsumidor:= TJSONObject.Create;
  if not FIdNummus.IsEmpty then
    FJsonConsumidor.AddPair('id', FIdNummus);
  FJsonConsumidor.AddPair('phone', ATelefone);
  FJsonConsumidor.AddPair('document_number', ADataset.FieldByName('CGC').AsString);
  FJsonConsumidor.AddPair('name', ADataset.FieldByName('NOME').AsString);
  if (not ADataset.FieldByName('NASC').AsString.IsEmpty) and (not ADataset.FieldByName('NASC').IsNull) then
    FJsonConsumidor.AddPair('birth_date', ADataset.FieldByName('NASC').AsString);
  FJsonConsumidor.AddPair('gender', 'N/I');
  FJsonConsumidor.AddPair('email', ADataset.FieldByName('EMAIL').AsString);
end;

function TNummusBase<T>.Mensagem: String;
begin
  Result:= FMensagem;
end;

function TNummusBase<T>.Cliente(AID: integer): iNummusBase<T>;
var
  vCliente: iEntidade;
  vTelefone: String;
begin
  Result:= Self;
  try
    vCliente:= TCliente.New;
    vCliente.EntidadeBase.TipoPesquisa(0);
    vCliente.EntidadeBase.TextoPesquisa(AID.ToString);
    vCliente.Consulta;
    if not vCliente.DtSrc.DataSet.IsEmpty then begin
      if vCliente.DtSrc.DataSet.FieldByName('FONE').AsString.IsEmpty and vCliente.DtSrc.DataSet.FieldByName('WHATSAPP').AsString.IsEmpty then
        raise Exception.Create('O telefone do cliente é obrigatório.');
      if vCliente.DtSrc.DataSet.FieldByName('CGC').AsString.IsEmpty then
        raise Exception.Create('O documento do cliente é obrigatório.');
      if not vCliente.DtSrc.DataSet.FieldByName('WHATSAPP').AsString.IsEmpty then
        vTelefone:= vCliente.DtSrc.DataSet.FieldByName('WHATSAPP').AsString
      else
        vTelefone:= vCliente.DtSrc.DataSet.FieldByName('FONE').AsString;
      if not vCliente.DtSrc.Dataset.FieldByName('DDD').asString.IsEmpty then begin
        if Copy(vTelefone, 1, 2) <> vCliente.DtSrc.Dataset.FieldByName('DDD').asString then
          vTelefone:= vCliente.DtSrc.Dataset.FieldByName('DDD').asString + vTelefone;
      end;
      if vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString.IsEmpty or vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').IsNull then begin
        FIDNummus := ConsultaClientePorDocTel(vCliente.DtSrc.DataSet.FieldByName('CGC').AsString, vTelefone, AID);
        if FIDNummus.IsEmpty then
          FIdNummus:= RegistraConsumidor(vCliente.DtSrc.DataSet, vTelefone);
        if not FIdNummus.IsEmpty then
          SalvaIdNummus(FIdNummus, AID)
        else
          raise Exception.Create('Erro: ' + FMensagem);
      end else
        FIdNummus:= vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString;
      MontaJsonCliente(vCliente.DtSrc.DataSet, vTelefone);
    end else
      raise Exception.Create('Cliente não encontrado!');
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
      raise Exception.Create(FMensagem);
    end;
  end;
end;

function TNummusBase<T>.ConsultaClientePorDocTel(ACgc, ATelefone: String; ACodCliente: integer): String;
var
  vResp: IResponse;
  JSONObject: TJSONObject;
  ContentArray: TJSONArray;
  ContentItem: TJSONObject;
begin
  Result:= '';
  try
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('customer')
              .ContentType('application/json')
              .AddHeader('x-api-key', FApiKey)
              .AddHeader('x-client-id', FClientID)
              .AddParam('limit', '1')
              .AddParam('document_number', TLib.SomenteNumero(ACgc))
              .Get;
    if vResp.StatusCode = 200 then begin
      FSucesso:= True;
      FMensagem:= vResp.Content;
      JSONObject := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
      try
        if Assigned(JSONObject) then begin
          ContentArray := JSONObject.GetValue<TJSONArray>('content');
          if Assigned(ContentArray) and (ContentArray.Count > 0) then begin
            ContentItem := ContentArray.Items[0] as TJSONObject;
            Result := ContentItem.GetValue<string>('id');
          end;
        end;
      finally
        JSONObject.Free;
      end;
    end else
      raise Exception.Create(vResp.Content);

    if not Result.IsEmpty then
      Exit;
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('customer')
              .ContentType('application/json')
              .AddHeader('x-api-key', FApiKey)
              .AddHeader('x-client-id', FClientID)
              .AddParam('limit', '1')
              .AddParam('phone', TLib.SomenteNumero(ATelefone))
              .Get;
    if vResp.StatusCode = 200 then begin
      JSONObject := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
      try
        if Assigned(JSONObject) then begin
          ContentArray := JSONObject.GetValue<TJSONArray>('content');
          if Assigned(ContentArray) and (ContentArray.Count > 0) then begin
            ContentItem := ContentArray.Items[0] as TJSONObject;
            Result := ContentItem.GetValue<string>('id');
          end;
        end;
      finally
        JSONObject.Free;
      end;
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

function TNummusBase<T>.ClienteIdNummus: String;
begin
  Result:= FIDNummus;
end;

function TNummusBase<T>.RegistraConsumidor(ADataset: TDataset; ATelefone: String): String;
var
  vResp: IResponse;
  vJsonResp: iJsonVal;
begin
  Result:= '';
  try
    FIDNummus:= '';
    MontaJsonCliente(ADataset, ATelefone);
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('customer')
              .ContentType('application/json')
              .AddHeader('x-api-key', FApiKey)
              .AddHeader('x-client-id', FClientID)
              .AddBody(FJsonConsumidor.ToString)
              .Post;
    if vResp.StatusCode = 200 then begin
      vJsonResp:= TJsonVal.New(vResp.Content);
      Result:= vJsonResp.GetValueAsString('id');
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

procedure TNummusBase<T>.SalvaIdNummus(AId: String; ACodigo: integer);
var
  vEntidade: iEntidade;
begin
  vEntidade:= TEntidade.New;
  vEntidade.EntidadeBase.Iquery.AddParametro('pCodigo', ACodigo);
  vEntidade.EntidadeBase.Iquery.AddParametro('pID', AId, ftString);
  vEntidade.EntidadeBase.Iquery.ExecQuery('update cadcli set ID_NUMMUS = :pID where codigo = :pCodigo');
end;

procedure TNummusBase<T>.Sucesso(AValue: Boolean);
begin
  FSucesso:= AValue;
end;

function TNummusBase<T>.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;
{ TNummusCashback }

class function TNummusCashback.New: iNummusCashback;
begin
  Result:= Self.Create;
end;

function TNummusCashback.AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
begin
  FProducts.Add(AProduct);
end;

constructor TNummusCashback.Create;
begin
  FNummusBase:= TNummusBase<iNummusCashback>.New(Self);
  FProducts := TObjectList<TProduct>.Create;
  FVenda:= TObjectList<TVendaNummus>.Create;
end;

destructor TNummusCashback.Destroy;
begin
  FProducts.Free;
  FVenda.Free;
  inherited;
end;

function TNummusCashback.GeraJson: String;
var
  JsonObj, JsonConsumidor: TJSONObject;
  JsonProducts: TJSONArray;
  Product: TProduct;
  Venda: TVendaNummus;
begin
  Result:= '';
  // Cria o objeto JSON principal
  JsonObj := TJSONObject.Create;
  try
    JsonConsumidor:= TJSONObject.ParseJSONValue(FNummusBase.JsonConsumidor) as TJSONObject;
    JsonObj.AddPair('customer', JsonConsumidor);
    // Adiciona produtos
    JsonProducts := TJSONArray.Create;
    for Product in FProducts do begin
      JsonProducts.Add(
        TJSONObject.Create
//          .AddPair('id', Product.Id)
          .AddPair('name', Product.Name)
          .AddPair('identifier', Product.Identifier)
          .AddPair('value_purchase', TJSONNumber.Create(Product.ValuePurchase))
      );
    end;
    JsonObj.AddPair('products', JsonProducts);
    // Adiciona informações adicionais
    for Venda in FVenda do begin
      JsonObj.AddPair('ticket_number', Venda.TicketNumber);
      JsonObj.AddPair('value_rescue', TJSONNumber.Create(Venda.ValueRescue));
      JsonObj.AddPair('value_discount', TJSONNumber.Create(Venda.ValueDiscount));
      JsonObj.AddPair('description_purchase', Venda.DescriptionPurchase);
      JsonObj.AddPair('dh_launch', FormatDateTime('yyyy-mm-ddThh:nn:ss', now));
    end;
    // Converte para string
    Result := JsonObj.ToString;
  finally
    JsonObj.Free;
  end;
end;

function TNummusCashback.NummusBase: iNummusBase<iNummusCashback>;
begin
  Result:= FNummusBase;
end;

procedure TNummusCashback.NovoCashback;
var
  vResp: IResponse;
begin
  try
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('cashback')
              .ContentType('application/json')
              .AddHeader('x-api-key', FNummusBase.ApiKey)
              .AddHeader('x-client-id', FNummusBase.ClientID)
              .AddBody(GeraJson)
              .Post;

    if vResp.StatusCode = 200 then begin
      FNummusBase.Sucesso(True);
      FNummusBase.Mensagem(vResp.Content);
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do begin
      FNummusBase.Sucesso(False);
      FNummusBase.Mensagem(E.Message);
    end;
  end;
end;

//function TNummusCashback.BuscaSaldo(AIDNummus: String): Currency;
//var
//  vResp: IResponse;
//begin
//  Result:= 0;
//  try
//    if AIDNummus.IsEmpty then
//      Exit;
//
//    vResp:= TRequest.New.BaseURL(C_URL)
//              .Timeout(C_TIMEOUT)
//              .Resource('cashback/amount?')
//              .ContentType('application/json')
//              .AddHeader('x-api-key', FNummusBase.ApiKey)
//              .AddHeader('x-client-id', FNummusBase.ClientID)
//              .AddParam('customer_id', AIDNummus)
//              .Get;
//
//    if vResp.StatusCode = 200 then begin
//      FSucesso:= True;
//      FMensagem:= vResp.Content;
//    end else
//      raise Exception.Create(vResp.Content);
//
//  except
//    on E:Exception do begin
//      FSucesso:= False;
//      FMensagem:= E.Message;
//    end;
//  end;
//end;
//
//function TNummusCashback.BuscaSaldo(ACodigo: integer): Currency;
//var
//  vResp: IResponse;
//  vCliente: iEntidade;
//  vJSONObjResult: TJSONObject;
//begin
//  Result:= 0;
//  try
//    vCliente:= TCliente.New;
//    vCliente.EntidadeBase.TipoPesquisa(0);
//    vCliente.EntidadeBase.TextoPesquisa(ACodigo.ToString);
//    vCliente.Consulta;
//
//    if vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').IsNull or vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString.IsEmpty then
//      Exit;
//
//    vResp:= TRequest.New.BaseURL(C_URL)
//              .Timeout(C_TIMEOUT)
//              .Resource('cashback/amount?')
//              .ContentType('application/json')
//              .AddHeader('x-api-key', FNummusBase.ApiKey)
//              .AddHeader('x-client-id', FNummusBase.ClientID)
//              .AddParam('customer_id', vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString)
//              .Get;
//
//    if vResp.StatusCode = 200 then begin
//      FSucesso:= True;
//      FMensagem:= vResp.Content;
//      vJSONObjResult := TJSONObject.ParseJSONValue(FMensagem) as TJSONObject;
//      try
//        if Assigned(vJSONObjResult) and vJSONObjResult.TryGetValue<Currency>('amount', Result) then
//          Exit(Result);
//      finally
//        vJSONObjResult.Free;
//      end;
//    end else
//      raise Exception.Create(vResp.Content);
//
//  except
//    on E:Exception do begin
//      FSucesso:= False;
//      FMensagem:= E.Message;
//    end;
//  end;
//end;
function TNummusCashback.SimulaResgate(ACodigo: integer; AValor: Currency): Currency;
var
  vResp: IResponse;
  vCliente: iEntidade;
  vJsonObj, vJSONObjResult: TJSONObject;
  vJson, vIdNummus: String;
begin
  Result:= 0;
  try
    vCliente:= TCliente.New;
    vCliente.EntidadeBase.TipoPesquisa(0);
    vCliente.EntidadeBase.TextoPesquisa(ACodigo.ToString);
    vCliente.Consulta;
    if vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').IsNull or vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString.IsEmpty then begin
      FNummusBase
        .Cliente(ACodigo);
      vIdNummus:= FNummusBase.ClienteIdNummus;
    end else
      vIdNummus:= vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString;
    vJsonObj := TJSONObject.Create;
    try
      vJsonObj.AddPair('customer_id', vIdNummus);
      vJsonObj.AddPair('value_purchase', TJSONNumber.Create(AValor));
      // Converte para string
      vJson := vJsonObj.ToString;
    finally
      vJsonObj.Free;
    end;
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('cashback/simulation')
              .ContentType('application/json')
              .AddHeader('x-api-key', FNummusBase.ApiKey)
              .AddHeader('x-client-id', FNummusBase.ClientID)
              .AddBody(vJson)
              .Post;
    if vResp.StatusCode = 200 then begin
      FNummusBase.Sucesso(True);
      FNummusBase.Mensagem(vResp.Content);
      vJSONObjResult := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
      try
        if AValor > 0 then begin
          if Assigned(vJSONObjResult) and vJSONObjResult.TryGetValue<Currency>('rescue_available', Result) then
            Exit(Result);
        end else begin
          if Assigned(vJSONObjResult) and vJSONObjResult.TryGetValue<Currency>('amount', Result) then
            Exit(Result);
        end;
      finally
        vJSONObjResult.Free;
      end;
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do begin
      FNummusBase.Sucesso(False);
      FNummusBase.Mensagem(E.Message);
    end;
  end;
end;

procedure TNummusCashback.CancelaCashback(AID: String; AMotivo: String);
var
  vResp: IResponse;
  vJsonObj: TJSONObject;
  vJsonStr: String;
begin
  try
    vJsonObj := TJSONObject.Create;
    try
      vJsonObj.AddPair('reason', AMotivo);
      vJsonStr := vJsonObj.ToString;
    finally
      vJsonObj.Free;
    end;
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('/cashback/' + AID + '/cancel')
              .ContentType('application/json')
              .AddHeader('x-api-key', FNummusBase.ApiKey)
              .AddHeader('x-client-id', FNummusBase.ClientID)
              .AddBody(vJsonStr)
              .Put;
    if vResp.StatusCode = 200 then begin
      FNummusBase.Sucesso(True);
      FNummusBase.Mensagem(vResp.Content);
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do begin
      FNummusBase.Sucesso(False);
      FNummusBase.Mensagem(E.Message);
    end;
  end;
end;

function TNummusCashback.AddVenda(AVenda: TVendaNummus): iNummusBase<iNummusCashback>;
begin
  FVenda.Add(AVenda);
end;

procedure TNummusCashback.BuscaCachbacks(AInicio, AFim: TDate; ACpf: String; AiTable: iTable);
var
  vResp: IResponse;
  vJsonObj: TJSONObject;
  vJsonPeriod, vJsonCustomer, vTeste: String;
begin
  try
    vJsonObj := TJSONObject.Create;
    try
      vJsonObj.AddPair('start', FormatDateTime('yyyy-mm-dd', AInicio));
      vJsonObj.AddPair('end', FormatDateTime('yyyy-mm-dd', AFim));
      vJsonPeriod := vJsonObj.ToString;
    finally
      vJsonObj.Free;
    end;
    vJsonObj := TJSONObject.Create;
    try
      vJsonObj.AddPair('document_number', TLib.SomenteNumero(ACpf));
      vJsonCustomer := vJsonObj.ToString;
    finally
      vJsonObj.Free;
    end;
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Accept('application/json')
              .Resource('cashback')
              .AddHeader('x-api-key', FNummusBase.ApiKey)
              .AddHeader('x-client-id', FNummusBase.ClientID)
              .AddParam('limit', '30')
              .AddParam('offset', '0')
              .AddParam('status', 'ACTIVE')
//              .AddParam('period', vJsonPeriod)
//              .AddParam('customer', vJsonCustomer)
              .Get;
    if vResp.StatusCode = 200 then begin
      FNummusBase.Sucesso(True);
      FNummusBase.Mensagem(vResp.Content);
      PopulaDatasetFromJson(vResp.Content, AiTable);
    end else
      raise Exception.Create(vResp.Content);
  except
    on E:Exception do begin
      FNummusBase.Sucesso(False);
      FNummusBase.Mensagem(E.Message);
    end;
  end;
end;
procedure TNummusCashback.PopulaDatasetFromJson(const AJsonStr: string; AiTable: iTable);
var
  JsonObj, ContentItem: TJSONObject;
  JsonArray: TJSONArray;
  ProductsArray: TJSONArray;
  I: Integer;
  vField: TField;
begin
  // Criar campos na MemTable se ainda não existirem
  if AiTable.Tabela.Fields.Count = 0 then begin
    AiTable.Tabela.FieldDefs.Add('ID', ftString, 30);
    AiTable.Tabela.FieldDefs.Add('NAME', ftString, 100);
    AiTable.Tabela.FieldDefs.Add('VALUE_PAID', ftCurrency);
    AiTable.Tabela.FieldDefs.Add('VALUE_CASHBACK', ftCurrency);
    AiTable.Tabela.FieldDefs.Add('DH_OPERATION', ftDateTime);
    AiTable.Tabela.FieldDefs.Add('EXCLUIR', ftBoolean);
    AiTable.CriaDataSet;
  end;

  // Criar o JSON Object
  JsonObj := TJSONObject.ParseJSONValue(aJsonStr) as TJSONObject;
  try
    JsonArray := JsonObj.GetValue<TJSONArray>('content');

    if Assigned(JsonArray) then begin
      for I := 0 to JsonArray.Count - 1 do begin
        ContentItem := JsonArray.Items[I] as TJSONObject;

        AiTable.Tabela.Append;
        AiTable.Tabela.FieldByName('ID').AsString := ContentItem.GetValue<string>('id', '');
        AiTable.Tabela.FieldByName('NAME').AsString := ContentItem.GetValue<TJSONObject>('customer').GetValue<string>('name', '');
        AiTable.Tabela.FieldByName('VALUE_PAID').AsCurrency := ContentItem.GetValue<Double>('value_paid', 0);
        AiTable.Tabela.FieldByName('VALUE_CASHBACK').AsCurrency := ContentItem.GetValue<Double>('value_cashback', 0);
        AiTable.Tabela.FieldByName('DH_OPERATION').AsString := ContentItem.GetValue<string>('dh_operation', '');
        AiTable.Tabela.FieldByName('EXCLUIR').AsBoolean := False;
        AiTable.Tabela.Post;
      end;
      vField:= AiTable.Tabela.FieldByName('EXCLUIR');
      vField.OnGetText:= CampoGetText;
    end;
  finally
    JsonObj.Free;
  end;
end;

procedure TNummusCashback.CampoGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text:= EmptyStr;
end;

end.
