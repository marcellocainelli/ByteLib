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
  Data.DB;

const
  C_TIMEOUT = 30000;
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

  TVenda = record
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
    function ClientID(AValue: String): iNummusBase<T>; overload;
    function ClientID: String; overload;
    function ApiKey(AValue: String): iNummusBase<T>; overload;
    function ApiKey: String; overload;
    function &End : T;
    function Cliente(AID: integer): iNummusBase<T>;
    function JsonConsumidor : iJsonObj;
  end;

  TNummusBase<T: IInterface> = class(TInterfacedObject, iNummusBase<T>)
  private
    [Weak]
    FParent: T;
    FMensagem: String;
    FSucesso: Boolean;
    FApiKey, FClientID: String;
    FJsonConsumidor: iJsonObj;
    constructor Create(Parent: T);
    destructor Destroy; override;
    function RegistraConsumidor(ACodigo: integer): String;
    procedure SalvaIdNummus(AId: String; ACodigo: integer);
  public
    class function New(Parent: T): iNummusBase<T>;
    function &End : T;
    function ClientID(AValue: String): iNummusBase<T>; overload;
    function ClientID: String; overload;
    function ApiKey(AValue: String): iNummusBase<T>; overload;
    function ApiKey: String; overload;
    function Cliente(AID: integer): iNummusBase<T>;
    function JsonConsumidor : iJsonObj;
  end;

  iNummusCashback = interface
    ['{C7CAF331-391F-4E1A-B510-BE0FB5F6D5A6}']
    function NummusBase: iNummusBase<iNummusCashback>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
    function BuscaSaldo(ACodigo: integer): Currency; overload;
    function BuscaSaldo(AIDNummus: String): Currency; overload;
    procedure NovoCashback(AVenda: TVenda);
  end;

  TNummusCashback = class(TInterfacedObject, iNummusCashback)
    private
      FNummusBase: iNummusBase<iNummusCashback>;
      FProducts: TObjectList<TProduct>;
      FSucesso: Boolean;
      FMensagem: String;
      constructor Create;
      destructor Destroy; override;
      function GeraJson(AVenda: TVenda): String;
    public
      class function New: iNummusCashback;
      function NummusBase: iNummusBase<iNummusCashback>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
      function BuscaSaldo(ACodigo: integer): Currency; overload;
      function BuscaSaldo(AIDNummus: String): Currency; overload;
      procedure NovoCashback(AVenda: TVenda);
  end;

implementation

{ TNebulazapBase<T> }

class function TNummusBase<T>.New(Parent: T): iNummusBase<T>;
begin
  Result:= Self.Create(Parent);
end;

constructor TNummusBase<T>.Create(Parent: T);
begin
  FJsonConsumidor:= TJsonObj.New;
  FMensagem:= '';
end;

destructor TNummusBase<T>.Destroy;
begin

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

function TNummusBase<T>.JsonConsumidor: iJsonObj;
begin
  Result:= FJsonConsumidor;
end;

function TNummusBase<T>.Cliente(AID: integer): iNummusBase<T>;
var
  vCliente: iEntidade;
  vIdNummus: String;
begin
  try
    vCliente:= TCliente.New;
    vCliente.EntidadeBase.TipoPesquisa(0);
    vCliente.EntidadeBase.TextoPesquisa(AID.ToString);
    vCliente.Consulta;

    if not vCliente.DtSrc.DataSet.IsEmpty then begin
      if vCliente.DtSrc.DataSet.FieldByName('FONE').AsString.IsEmpty then
        raise Exception.Create('O telefone do cliente é obrigatório.');
      if vCliente.DtSrc.DataSet.FieldByName('CGC').AsString.IsEmpty then
        raise Exception.Create('O documento do cliente é obrigatório.');

      if vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString.IsEmpty or vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').IsNull then begin
        vIdNummus:= RegistraConsumidor(AID);
        if not vIdNummus.IsEmpty then
          SalvaIdNummus(vIdNummus, AID)
        else
          raise Exception.Create('Erro: ' + FMensagem);
      end else
        vIdNummus:= vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString;
      FJsonConsumidor.AddPair('id', vIdNummus);
      FJsonConsumidor.AddPair('phone', vCliente.DtSrc.DataSet.FieldByName('FONE').AsString);
      FJsonConsumidor.AddPair('document_number', vCliente.DtSrc.DataSet.FieldByName('CGC').AsString);
      FJsonConsumidor.AddPair('name', vCliente.DtSrc.DataSet.FieldByName('NOME').AsString);
      if not vCliente.DtSrc.DataSet.FieldByName('DTNASC').AsString.IsEmpty then
        FJsonConsumidor.AddPair('birth_date', vCliente.DtSrc.DataSet.FieldByName('DTNASC').AsString);
      FJsonConsumidor.AddPair('gender', '''N/I''');
      FJsonConsumidor.AddPair('email', vCliente.DtSrc.DataSet.FieldByName('EMAIL').AsString);
      FJsonConsumidor.AddPair('type_customer', '');
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

function TNummusBase<T>.RegistraConsumidor(ACodigo: integer): String;
var
  vResp: IResponse;
  vJsonResp: iJsonVal;
begin
  Result:= '';
  try
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
  FProducts := TObjectList<TProduct>.Create;
end;

destructor TNummusCashback.Destroy;
begin
  FProducts.Free;
  inherited;
end;

function TNummusCashback.GeraJson(AVenda: TVenda): String;
var
  JsonObj: TJSONObject;
  JsonProducts: TJSONArray;
  Product: TProduct;
begin
  // Cria o objeto JSON principal
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('customer', FNummusBase.JsonConsumidor.ToJsonObject);

    // Adiciona produtos
    JsonProducts := TJSONArray.Create;
    for Product in FProducts do begin
      JsonProducts.Add(
        TJSONObject.Create
          .AddPair('id', Product.Id)
          .AddPair('name', Product.Name)
          .AddPair('identifier', Product.Identifier)
          .AddPair('value_purchase', TJSONNumber.Create(Product.ValuePurchase))
      );
    end;
    JsonObj.AddPair('products', JsonProducts);

    // Adiciona informações adicionais
    JsonObj
      .AddPair('ticket_number', AVenda.TicketNumber)
      .AddPair('value_rescue', TJSONNumber.Create(AVenda.ValueRescue))
      .AddPair('value_discount', TJSONNumber.Create(AVenda.ValueDiscount))
      .AddPair('description_purchase', AVenda.DescriptionPurchase)
      .AddPair('dh_launch', FormatDateTime('yyyy-mm-ddThh:nn:ss', now));

    // Converte para string
    Result := JsonObj.ToString;
  finally
    JsonObj.Free;
  end;
end;

function TNummusCashback.Mensagem: String;
begin
  Result:= FMensagem;
end;

function TNummusCashback.NummusBase: iNummusBase<iNummusCashback>;
begin
  FNummusBase:= TNummusBase<iNummusCashback>.New(Self);
end;

function TNummusCashback.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

procedure TNummusCashback.NovoCashback(AVenda: TVenda);
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
              .AddBody(GeraJson(AVenda))
              .Post;

    if vResp.StatusCode = 200 then begin
      FSucesso:= True;
      FMensagem:= vResp.Content;
    end else
      raise Exception.Create(vResp.Content);

  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

function TNummusCashback.BuscaSaldo(AIDNummus: String): Currency;
var
  vResp: IResponse;
begin
  Result:= 0;
  try
    if AIDNummus.IsEmpty then
      Exit;

    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('cashback/amount?')
              .ContentType('application/json')
              .AddHeader('x-api-key', FNummusBase.ApiKey)
              .AddHeader('x-client-id', FNummusBase.ClientID)
              .AddParam('customer_id', AIDNummus)
              .Get;

    if vResp.StatusCode = 200 then begin
      FSucesso:= True;
      FMensagem:= vResp.Content;
    end else
      raise Exception.Create(vResp.Content);

  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

function TNummusCashback.BuscaSaldo(ACodigo: integer): Currency;
var
  vResp: IResponse;
  vCliente: iEntidade;
begin
  Result:= 0;
  try
    vCliente:= TCliente.New;
    vCliente.EntidadeBase.TipoPesquisa(0);
    vCliente.EntidadeBase.TextoPesquisa(ACodigo.ToString);
    vCliente.Consulta;

    if vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').IsNull or vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString.IsEmpty then
      Exit;

    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('cashback/amount?')
              .ContentType('application/json')
              .AddHeader('x-api-key', FNummusBase.ApiKey)
              .AddHeader('x-client-id', FNummusBase.ClientID)
              .AddParam('customer_id', vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString)
              .Get;

    if vResp.StatusCode = 200 then begin
      FSucesso:= True;
      FMensagem:= vResp.Content;
    end else
      raise Exception.Create(vResp.Content);

  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;

end.
