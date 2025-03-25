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
  Generics.Collections;

const
  C_TIMEOUT = 30000;

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
    DhLaunch: TDateTime;
  end;

  TProduct = class
    Id: string;
    Name: string;
    Identifier: string;
    ValuePurchase: Double;
  end;

  iNummusBase<T> = interface
    ['{D9A2B355-6B29-4EC9-BE04-CD7B88E470F6}']
    function ClientID(AValue: String): iNummusBase<T>;
    function ApiKey(AValue: String): iNummusBase<T>;
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
    function Auth: String;
  public
    class function New(Parent: T): iNummusBase<T>;
    function &End : T;
    function ClientID(AValue: String): iNummusBase<T>;
    function ApiKey(AValue: String): iNummusBase<T>;
    function Cliente(AID: integer): iNummusBase<T>;
    function JsonConsumidor : iJsonObj;
  end;

  iNummusCashback = interface
    ['{C7CAF331-391F-4E1A-B510-BE0FB5F6D5A6}']
    function NummusBase: iNummusBase<iNummusCashback>;
    function Sucesso: Boolean;
    function Mensagem: String;
    function AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
    procedure NovoCashback;
  end;

  TNummusCashback = class(TInterfacedObject, iNummusCashback)
    private
      FNummusBase: iNummusBase<iNummusCashback>;
      FProducts: TObjectList<TProduct>;
      FSucesso: Boolean;
      FMensagem: String;
      constructor Create;
      destructor Destroy; override;
      function GeraJson: String;
    public
      class function New: iNummusCashback;
      function NummusBase: iNummusBase<iNummusCashback>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function AddProduct(AProduct: TProduct): iNummusBase<iNummusCashback>;
      procedure NovoCashback;
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

function TNummusBase<T>.ClientID(AValue: String): iNummusBase<T>;
begin
  Result:= Self;
  FClientID:= AValue;
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
begin
  vCliente:= TCliente.New;
  vCliente.EntidadeBase.TipoPesquisa(0);
  vCliente.EntidadeBase.TextoPesquisa(AID.ToString);
  vCliente.Consulta;

  if not vCliente.DtSrc.DataSet.IsEmpty then begin
    if not vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString.IsEmpty then
      FJsonConsumidor.AddPair('id', vCliente.DtSrc.DataSet.FieldByName('ID_NUMMUS').AsString);
    FJsonConsumidor.AddPair('phone', vCliente.DtSrc.DataSet.FieldByName('FONE').AsString);
    FJsonConsumidor.AddPair('document_number', vCliente.DtSrc.DataSet.FieldByName('CGC').AsString);
    FJsonConsumidor.AddPair('name', vCliente.DtSrc.DataSet.FieldByName('NOME').AsString);
    if not vCliente.DtSrc.DataSet.FieldByName('DTNASC').AsString.IsEmpty then
      FJsonConsumidor.AddPair('birth_date', vCliente.DtSrc.DataSet.FieldByName('DTNASC').AsString);
    FJsonConsumidor.AddPair('gender', '''N/I''');
    FJsonConsumidor.AddPair('email', vCliente.DtSrc.DataSet.FieldByName('EMAIL').AsString);
    FJsonConsumidor.AddPair('type_customer', '');
  end else begin
    FSucesso:= False;
    FMensagem:= 'Cliente não encontrado!';
    raise Exception.Create(FMensagem);
  end;
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

function TNummusCashback.GeraJson: String;
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
    for Product in FProducts do
    begin
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
      .AddPair('ticket_number', FTicketNumber)
      .AddPair('value_rescue', TJSONNumber.Create(FValueRescue))
      .AddPair('value_discount', TJSONNumber.Create(FValueDiscount))
      .AddPair('description_purchase', FDescriptionPurchase)
      .AddPair('dh_launch', FormatDateTime('yyyy-mm-ddThh:nn:ss', FDhLaunch));

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

procedure TNummusCashback.NovoCashback;
var
  vJsonCashback: TJSONObject;
begin
  try
    vJsonCashback:= TJSONObject.Create;
    try
      vJsonCashback.AddPair('customer', FNummusBase.JsonConsumidor.ToJsonObject);
    finally
      vJsonCashback.Free;
    end;
  except
    on E:Exception do begin

    end;
  end;
end;

end.
