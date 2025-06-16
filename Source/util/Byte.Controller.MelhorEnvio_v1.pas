unit Byte.Controller.MelhorEnvio_v1;
interface
uses
  System.SysUtils, System.Classes, System.JSON, RESTRequest4D, Model.Entidade.Interfaces, uEntidade,
  Byte.Lib, System.DateUtils, Data.DB, System.Generics.Collections, uFilial, uCliente;
const
  C_TIMEOUT = 30000;
  C_URL_SANDBOX = 'https://sandbox.melhorenvio.com.br/';
  C_URL_PRODUCAO = 'https://melhorenvio.com.br/';
  C_REDIRECT = 'https://doutorbytesistemas.com.br/';
type
  TProduct = class
    Id: string;
    Width: Double;
    Height: Double;
    Length: Double;
    Weight: Double;
    InsuranceValue: Double;
    Quantity: Int32;
  end;
  TVolumes = class
    Width: Double;
    Height: Double;
    Length: Double;
    Weight: Double;
  end;
  iMelhorEnvioBase<T> = interface
    ['{F6F5167E-917F-4CCC-9CDC-BAA373315934}']
    function Sucesso: Boolean; overload;
    procedure Sucesso(AValue: Boolean); overload;
    function Mensagem: String; overload;
    procedure Mensagem(AValue: String); overload;
    function ClientID(AValue: Integer): iMelhorEnvioBase<T>; overload;
    function ClientID: Integer; overload;
    function SecretKey(AValue: String): iMelhorEnvioBase<T>; overload;
    function SecretKey: String; overload;
    function Code(AValue: String): iMelhorEnvioBase<T>;
    function Authorize: String;
    function RefreshToken: iMelhorEnvioBase<T>;
    function RefreshTokenToString: String;
    function AccessToken: iMelhorEnvioBase<T>;
    function AccessTokenToString: String;
    function CodFilial: integer; overload;
    function CodFilial(AValue: integer): iMelhorEnvioBase<T>; overload;
    function &End : T;
  end;
  TMelhorEnvioBase<T: IInterface> = class(TInterfacedObject, iMelhorEnvioBase<T>)
  private
    [Weak]
    FParent: T;
    FMensagem: String;
    FSucesso: Boolean;
    FSecretKey, FCode, FRefreshToken, FAccessToken: String;
    FDateToken, FDateRefreshToken: TDateTime;
    FCodFilial, FClientID: integer;
    constructor Create(Parent: T);
    destructor Destroy; override;
    procedure GetDados;
    procedure SalvaToken(AJson: String);
    procedure VerificarERenovarTokens;
  public
    class function New(Parent: T): iMelhorEnvioBase<T>;
    function &End : T;
    function Sucesso: Boolean; overload;
    procedure Sucesso(AValue: Boolean); overload;
    function Mensagem: String; overload;
    procedure Mensagem(AValue: String); overload;
    function ClientID(AValue: Integer): iMelhorEnvioBase<T>; overload;
    function ClientID: Integer; overload;
    function SecretKey(AValue: String): iMelhorEnvioBase<T>; overload;
    function SecretKey: String; overload;
    function Code(AValue: String): iMelhorEnvioBase<T>;
    function Authorize: String;
    function RefreshToken: iMelhorEnvioBase<T>;
    function RefreshTokenToString: String;
    function AccessToken: iMelhorEnvioBase<T>;
    function AccessTokenToString: String;
    function CodFilial: integer; overload;
    function CodFilial(AValue: integer): iMelhorEnvioBase<T>; overload;
  end;
  iMelhorEnvio = interface
    ['{4F12FCF5-F635-44B7-9625-C22CAD6F882B}']
    function Sucesso: Boolean;
    function Mensagem: String;
    function AddProduct(AProduct: TProduct): iMelhorEnvio;
    function CalculoFrete(AFrom, ATo: String): String;
    function AdicionaFreteCarrinho(AIdTransportadora, AIdCliente: integer; APackages: String; AChaveNota: String = ''): String;
    function ListaItensCarrinho(ADataset: TDataset): iMelhorEnvio;
    function RemoveItemCarrinho(AOrderID: String): iMelhorEnvio;
    procedure CompraFrete(AIdList: TDataset);
    function SaldoUsuario: Currency;
    procedure GeraEtiqueta(AIdOrder: String);
    procedure ImprimeEtiquetaArquivo(AIdOrder: String; AFile: TStream);
    function ListarEtiquetas(AStatus: String; ADataset: TDataset): iMelhorEnvio;
    function Base: iMelhorEnvioBase<iMelhorEnvio>;
  end;
  TMelhorEnvio = class(TInterfacedObject, iMelhorEnvio)
    private
      FMelhorEnvioBase: iMelhorEnvioBase<iMelhorEnvio>;
      FProdutos: TObjectList<TProduct>;
      FVolumes: TObjectList<TVolumes>;
      constructor Create;
      destructor Destroy; override;
      procedure PreencheDadosRemetente(AJsonObject: TJSONObject);
      procedure PreencheDadosDestinatario(AIdCliente: integer; AJsonObject: TJSONObject);
      procedure SeparaPackages(APackages: String);
    public
      class function New: iMelhorEnvio;
      function Base: iMelhorEnvioBase<iMelhorEnvio>;
      function Sucesso: Boolean;
      function Mensagem: String;
      function AddProduct(AProduct: TProduct): iMelhorEnvio;
      function CalculoFrete(AFrom, ATo: String): String;
      function AdicionaFreteCarrinho(AIdTransportadora, AIdCliente: integer; APackages: String; AChaveNota: String = ''): String;
      function ListaItensCarrinho(ADataset: TDataset): iMelhorEnvio;
      function RemoveItemCarrinho(AOrderID: String): iMelhorEnvio;
      procedure CompraFrete(AIdList: TDataset);
      procedure GeraEtiqueta(AIdOrder: String);
      procedure ImprimeEtiquetaArquivo(AIdOrder: String; AFile: TStream);
      function ListarEtiquetas(AStatus: String; ADataset: TDataset): iMelhorEnvio;
      function SaldoUsuario: Currency;
  end;
implementation
{ TMelhorEnvioBase<T> }
class function TMelhorEnvioBase<T>.New(Parent: T): iMelhorEnvioBase<T>;
begin
  Result:= Self.Create(Parent);
end;
constructor TMelhorEnvioBase<T>.Create(Parent: T);
begin
  FParent:= Parent;
  FMensagem:= '';
  GetDados;
  if not FCode.IsEmpty then
    VerificarERenovarTokens;
end;
destructor TMelhorEnvioBase<T>.Destroy;
begin
  inherited;
end;
function TMelhorEnvioBase<T>.ClientID(AValue: Integer): iMelhorEnvioBase<T>;
begin
  Result:= Self;
  FClientID:= AValue;
end;
function TMelhorEnvioBase<T>.ClientID: Integer;
begin
  Result:= FClientID;
end;
function TMelhorEnvioBase<T>.&End: T;
begin
  Result:= FParent;
end;
function TMelhorEnvioBase<T>.Mensagem: String;
begin
  Result:= FMensagem;
end;
procedure TMelhorEnvioBase<T>.Mensagem(AValue: String);
begin
  FMensagem:= AValue;
end;
function TMelhorEnvioBase<T>.SecretKey(AValue: String): iMelhorEnvioBase<T>;
begin
  Result:= Self;
  FSecretKey:= AValue;
end;
function TMelhorEnvioBase<T>.SecretKey: String;
begin
  Result:= FSecretKey;
end;
procedure TMelhorEnvioBase<T>.Sucesso(AValue: Boolean);
begin
  FSucesso:= AValue;
end;
function TMelhorEnvioBase<T>.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;
function TMelhorEnvioBase<T>.Code(AValue: String): iMelhorEnvioBase<T>;
begin
  Result:= Self;
  FCode:= AValue;
end;
function TMelhorEnvioBase<T>.CodFilial: integer;
begin
  Result:= FCodFilial;
end;
function TMelhorEnvioBase<T>.CodFilial(AValue: integer): iMelhorEnvioBase<T>;
begin
  FCodFilial:= AValue;
end;
function TMelhorEnvioBase<T>.AccessTokenToString: String;
begin
  Result:= FAccessToken;
end;
function TMelhorEnvioBase<T>.Authorize: String;
var
  vScope: String;
begin
  vScope:=
    'cart-read cart-write companies-read companies-write coupons-read coupons-write notifications-read orders-read products-read ' +
    'products-write purchases-read shipping-calculate shipping-cancel shipping-checkout shipping-companies shipping-generate shipping-preview ' +
    'shipping-print shipping-share shipping-tracking ecommerce-shipping transactions-read users-read users-write';
  Result:=
    C_URL_SANDBOX +
    Format('oauth/authorize?%s=%s&%s=%s&%s=%s&%s=%s',
      ['client_id', FClientID.ToString,
       'redirect_uri', C_REDIRECT,
       'response_type', 'code',
       'scope', vScope
      ]
    );
end;
function TMelhorEnvioBase<T>.RefreshToken: iMelhorEnvioBase<T>;
var
  vResp: IResponse;
  vParams: String;
begin
  try
    vParams:= Format('grant_type=%s&client_id=%s&client_secret=%s&redirect_uri=%s&code=%s', ['authorization_code', FClientID.ToString, FSecretKey, C_REDIRECT, FCode]);
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('oauth/token')
              .ContentType('application/x-www-form-urlencoded')
              .Accept('application/json')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .AddBody(vParams)
              .Post;
    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content)
    else
      SalvaToken(vResp.Content);
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;
function TMelhorEnvioBase<T>.RefreshTokenToString: String;
begin
  Result:= FRefreshToken;
end;
function TMelhorEnvioBase<T>.AccessToken: iMelhorEnvioBase<T>;
var
  vResp: IResponse;
  vParams: String;
begin
  try
    vParams:= Format('grant_type=%s&client_id=%s&client_secret=%s&refresh_token=%s', ['refresh_token', FClientID.ToString, FSecretKey, FRefreshToken]);
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('oauth/token')
              .ContentType('application/x-www-form-urlencoded')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .AddBody(vParams)
              .Post;
    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content)
    else
      SalvaToken(vResp.Content);
  except
    on E:Exception do begin
      FSucesso:= False;
      FMensagem:= E.Message;
    end;
  end;
end;
procedure TMelhorEnvioBase<T>.VerificarERenovarTokens;
begin
  if Date >= FDateToken then begin
    if Date >= FDateRefreshToken then
      RefreshToken
    else
      AccessToken;
  end;
end;
procedure TMelhorEnvioBase<T>.SalvaToken(AJson: String);
var
  JSONObject: TJSONObject;
  vSalvaToken: iEntidade;
begin
  JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(AJSON), 0) as TJSONObject;
  if JSONObject <> nil then begin
    try
      FAccessToken := JSONObject.GetValue<String>('access_token');
      FRefreshToken := JSONObject.GetValue<String>('refresh_token');
      FDateToken:= IncMonth(Today, 1);
      FDateRefreshToken:= IncMonth(Today, 1);
      vSalvaToken:= TEntidade.New;
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pRefreshToken', FRefreshToken, ftString);
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pREFRESH_TOKEN_EXPIRA', FDateRefreshToken, ftDateTime);
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pToken', FAccessToken, ftString);
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pTOKEN_EXPIRA', FDateToken, ftDateTime);
      vSalvaToken.EntidadeBase.Iquery.ExecQuery(
        'UPDATE CONFIG_MELHORENVIO SET REFRESH_TOKEN = :pRefreshToken, TOKEN = :pToken, REFRESH_TOKEN_EXPIRA =:pREFRESH_TOKEN_EXPIRA, TOKEN_EXPIRA = :pTOKEN_EXPIRA ' +
        'WHERE ID = 1'
      );
    finally
      JSONObject.Free;
    end;
  end;
end;
procedure TMelhorEnvioBase<T>.GetDados;
var
  vConfigMelhorEnvio: iEntidade;
begin
  vConfigMelhorEnvio:= TEntidade.New;
  vConfigMelhorEnvio.EntidadeBase.TextoSQL('SELECT * FROM CONFIG_MELHORENVIO');
  vConfigMelhorEnvio.Consulta;
  FCode:= TLib.Crypt(vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('CODE').AsString, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL');
  FRefreshToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('REFRESH_TOKEN').AsString;
  FAccessToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('TOKEN').AsString;
  FDateToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('TOKEN_EXPIRA').AsDateTime;
  FDateRefreshToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('REFRESH_TOKEN_EXPIRA').AsDateTime;
  FClientID:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('CLIENTID').AsInteger;
  FSecretKey:= TLib.Crypt(vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('SECRETID').AsString, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL');
end;
{ TMelhorEnvio }
class function TMelhorEnvio.New: iMelhorEnvio;
begin
  Result:= Self.Create;
end;
constructor TMelhorEnvio.Create;
begin
  FMelhorEnvioBase:= TMelhorEnvioBase<iMelhorEnvio>.New(Self);
  FProdutos:= TObjectList<TProduct>.Create;
  FVolumes:= TObjectList<TVolumes>.Create;
end;
destructor TMelhorEnvio.Destroy;
begin
  FProdutos.Free;
  FVolumes.Free;
  inherited;
end;

function TMelhorEnvio.Sucesso: Boolean;
begin
  Result:= FMelhorEnvioBase.Sucesso;
end;
function TMelhorEnvio.Mensagem: String;
begin
  Result:= FMelhorEnvioBase.Mensagem;
end;
function TMelhorEnvio.AddProduct(AProduct: TProduct): iMelhorEnvio;
begin
  FProdutos.Add(AProduct);
end;
function TMelhorEnvio.CalculoFrete(AFrom, ATo: String): String;
var
  JsonObj, vJsonObjFrom, vJsonObjTo, vJsonObjOptions : TJSONObject;
  JsonProdutos: TJSONArray;
  vResp: IResponse;
  Product: TProduct;
begin
  Result:= '';
  try
    JsonObj := TJSONObject.Create;
    try
      vJsonObjFrom:= TJSONObject.Create;
      vJsonObjFrom.AddPair('postal_code', AFrom);
      vJsonObjTo:= TJSONObject.Create;
      vJsonObjTo.AddPair('postal_code', ATo);
      // Adiciona produtos
      JsonProdutos := TJSONArray.Create;
      for Product in FProdutos do begin
        JsonProdutos.Add(
          TJSONObject.Create
            .AddPair('id', Product.Id)
            .AddPair('width', Product.Width)
            .AddPair('height', Product.Height)
            .AddPair('length', Product.Length)
            .AddPair('weight', Product.Weight)
            .AddPair('insurance_value', Product.InsuranceValue)
            .AddPair('quantity', Product.Quantity)
        );
      end;
      vJsonObjOptions:= TJSONObject.Create;
      vJsonObjOptions.AddPair('receipt', false);
      vJsonObjOptions.AddPair('own_hand', false);
      JsonObj.AddPair('from', vJsonObjFrom);
      JsonObj.AddPair('to', vJsonObjTo);
      JsonObj.AddPair('products', JsonProdutos);
      JsonObj.AddPair('options', vJsonObjOptions);

      vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
                .Timeout(C_TIMEOUT)
                .Resource('api/v2/me/shipment/calculate')
                .ContentType('application/json')
                .AcceptEncoding('application/json')
                .AddHeader('Authorization', 'Bearer token')
                .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
                .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
                .AddBody(JsonObj.ToString)
                .Post;
      if vResp.StatusCode <> 200 then
        raise Exception.Create(vResp.Content)
      else begin
        FMelhorEnvioBase.Sucesso(True);
        FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');
        Result:= vResp.Content;
      end;
    finally
      JsonObj.Free;
    end;
  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;
procedure TMelhorEnvio.PreencheDadosDestinatario(AIdCliente: integer; AJsonObject: TJSONObject);
var
  vCliente: iEntidade;
begin
  vCliente:= TCliente.New;
  vCliente.EntidadeBase.TipoPesquisa(0);
  vCliente.EntidadeBase.TextoPesquisa(AIdCliente.ToString);
  vCliente.Consulta;
//  AJsonObject.AddPair('name', vCliente.DtSrc.DataSet.FieldByName('NOME').AsString);
//  AJsonObject.AddPair('phone', vCliente.DtSrc.DataSet.FieldByName('FONE').AsString);
//  AJsonObject.AddPair('email', vCliente.DtSrc.DataSet.FieldByName('EMAIL').AsString);
//  if vCliente.DtSrc.DataSet.FieldByName('TIPO').AsString = 'F' then
//    AJsonObject.AddPair('document', vCliente.DtSrc.DataSet.FieldByName('CGC').AsString)
//  else
//    AJsonObject.AddPair('company_document', vCliente.DtSrc.DataSet.FieldByName('CGC').AsString);
//  AJsonObject.AddPair('state_register', vCliente.DtSrc.DataSet.FieldByName('IE').AsString);
//  AJsonObject.AddPair('address', vCliente.DtSrc.DataSet.FieldByName('ENDERECO').AsString);
//  AJsonObject.AddPair('complement', vCliente.DtSrc.DataSet.FieldByName('END_COMPLEMENTO').AsString);
//  AJsonObject.AddPair('number', vCliente.DtSrc.DataSet.FieldByName('NUMERO').AsString);
//  AJsonObject.AddPair('district', vCliente.DtSrc.DataSet.FieldByName('BAIRRO').AsString);
//  AJsonObject.AddPair('city', vCliente.DtSrc.DataSet.FieldByName('CIDADE').AsString);
//  AJsonObject.AddPair('country_id', vCliente.DtSrc.DataSet.FieldByName('COD_PAIS').AsString);
//  AJsonObject.AddPair('postal_code', vCliente.DtSrc.DataSet.FieldByName('CEP').AsString);
//  AJsonObject.AddPair('state_abbr', vCliente.DtSrc.DataSet.FieldByName('UF').AsString);
  AJsonObject.AddPair('name', 'Marcello Cainelli');
  AJsonObject.AddPair('phone', '14 3522-2000');
  AJsonObject.AddPair('email', 'contato@doutorbytesistemas.com.br');
  AJsonObject.AddPair('document', '130.991.878-36');
  AJsonObject.AddPair('state_register', '19808930');
  AJsonObject.AddPair('address', 'Rua Anita Garibaldi');
  AJsonObject.AddPair('number', '95');
  AJsonObject.AddPair('district', 'Se');
  AJsonObject.AddPair('city', 'SÃO PAULO');
  AJsonObject.AddPair('postal_code', '01018020');
  AJsonObject.AddPair('state_abbr', 'SP');
end;
procedure TMelhorEnvio.PreencheDadosRemetente(AJsonObject: TJSONObject);
var
  vFilial: iEntidade;
begin
  vFilial:= TFilial.New;
  vFilial.EntidadeBase.TipoPesquisa(1);
  vFilial.EntidadeBase.AddParametro('CodFilial', FMelhorEnvioBase.CodFilial);
  vFilial.Consulta;
//  AJsonObject.AddPair('name', vFilial.DtSrc.DataSet.FieldByName('RAZAOSOCIAL').AsString);
//  AJsonObject.AddPair('phone', vFilial.DtSrc.DataSet.FieldByName('FONE').AsString);
//  AJsonObject.AddPair('email', vFilial.DtSrc.DataSet.FieldByName('EMAIL').AsString);
////  AJsonObject.AddPair('document', vFilial.DtSrc.DataSet.FieldByName('CNPJ').AsString);
//  AJsonObject.AddPair('company_document', vFilial.DtSrc.DataSet.FieldByName('CNPJ').AsString);
//  AJsonObject.AddPair('state_register', vFilial.DtSrc.DataSet.FieldByName('IE').AsString);
//  AJsonObject.AddPair('address', vFilial.DtSrc.DataSet.FieldByName('ENDERECO').AsString);
////  AJsonObject.AddPair('complement', vFilial.DtSrc.DataSet.FieldByName('').AsString);
//  AJsonObject.AddPair('number', vFilial.DtSrc.DataSet.FieldByName('NUMERO').AsString);
//  AJsonObject.AddPair('district', vFilial.DtSrc.DataSet.FieldByName('BAIRRO').AsString);
//  AJsonObject.AddPair('city', vFilial.DtSrc.DataSet.FieldByName('CIDADE').AsString);
////  AJsonObject.AddPair('country_id', vFilial.DtSrc.DataSet.FieldByName('').AsString);
//  AJsonObject.AddPair('postal_code', vFilial.DtSrc.DataSet.FieldByName('CEP').AsString);
//  AJsonObject.AddPair('state_abbr', vFilial.DtSrc.DataSet.FieldByName('UF').AsString);
  AJsonObject.AddPair('name', 'MARCELLO CAINELLI');
  AJsonObject.AddPair('phone', '14 99735-5168');
  AJsonObject.AddPair('email', 'marcelloteste@gmail.com');
  AJsonObject.AddPair('company_document', '08.648.367/0001-28');
  AJsonObject.AddPair('state_register', '564086930115');
  AJsonObject.AddPair('address', 'Rua Professor Doutor Araújo');
  AJsonObject.AddPair('number', '1575');
  AJsonObject.AddPair('district', 'Centro');
  AJsonObject.AddPair('city', 'Pelotas');
  AJsonObject.AddPair('postal_code', '96020360');
  AJsonObject.AddPair('state_abbr', 'RS');
end;

procedure TMelhorEnvio.SeparaPackages(APackages: String);
var
  LJsonValue, LPackage: TJSONValue;
  LJsonObject, LDimensions: TJSONObject;
  LJsonArray: TJSONArray;
  LVolume: TVolumes;
begin
  // Limpa a lista existente antes de preencher
  if Assigned(FVolumes) then
    FVolumes.Clear
  else
    FVolumes := TObjectList<TVolumes>.Create;
  LJsonValue := TJSONObject.ParseJSONValue(APackages);
  try
    if LJsonValue is TJSONObject then begin
      LJsonObject := LJsonValue as TJSONObject;
      LJsonArray := LJsonObject.GetValue('packages') as TJSONArray;
      if Assigned(LJsonArray) then begin
        for LPackage in LJsonArray do begin
          if LPackage is TJSONObject then begin
            LJsonObject := LPackage as TJSONObject;
            // Cria um novo objeto TVolumes para cada pacote
            LVolume := TVolumes.Create;
            LVolume.Weight := StrToFloat(StringReplace(LJsonObject.GetValue('weight').Value, '.', ',', [rfReplaceAll, rfIgnoreCase]));
            // Extrai as dimensões
            LDimensions := LJsonObject.GetValue('dimensions') as TJSONObject;
            if Assigned(LDimensions) then begin
              LDimensions.TryGetValue<Double>('height', LVolume.Height);
              LDimensions.TryGetValue<Double>('width', LVolume.Width);
              LDimensions.TryGetValue<Double>('length', LVolume.Length);
            end;
            // Adiciona o volume à lista
            FVolumes.Add(LVolume);
          end;
        end;
      end;
    end;
  finally
    LJsonValue.Free;
  end;
end;
function TMelhorEnvio.AdicionaFreteCarrinho(AIdTransportadora, AIdCliente: integer; APackages: String; AChaveNota: String = ''): String;
var
  vResp: IResponse;
  JsonObj, vJsonObjFrom, vJsonObjTo, vJsonObjOptions, vJsonObjOptions_Invoice : TJSONObject;
  JsonProdutos, JsonVolumes: TJSONArray;
  Product: TProduct;
  Volume: TVolumes;
  vInsuranceValue: Currency;
begin
  vInsuranceValue:= 0;
  try
    JsonObj:= TJSONObject.Create;
    try
      vJsonObjFrom:= TJSONObject.Create;
      PreencheDadosRemetente(vJsonObjFrom);
      vJsonObjTo:= TJSONObject.Create;
      PreencheDadosDestinatario(AIdCliente, vJsonObjTo);
      SeparaPackages(APackages);
      // Adiciona produtos
      JsonProdutos := TJSONArray.Create;
      for Product in FProdutos do begin
        JsonProdutos.Add(
          TJSONObject.Create
            .AddPair('id', Product.Id)
            .AddPair('unitary_value', Product.InsuranceValue)
            .AddPair('quantity', Product.Quantity)
        );
        vInsuranceValue:= vInsuranceValue + Product.InsuranceValue;
      end;
      // Adiciona volumes
      JsonVolumes := TJSONArray.Create;
      for Volume in FVolumes do begin
        JsonVolumes.Add(
          TJSONObject.Create
            .AddPair('width', Volume.Width)
            .AddPair('height', Volume.Height)
            .AddPair('length', Volume.Length)
            .AddPair('weight', 0.1)//Volume.Weight)
        );
      end;
      vJsonObjOptions:= TJSONObject.Create;
      vJsonObjOptions.AddPair('receipt', false);
      vJsonObjOptions.AddPair('own_hand', false);
      vJsonObjOptions.AddPair('reverse', false);
      vJsonObjOptions.AddPair('non_commercial', false);
      vJsonObjOptions.AddPair('insurance_value', vInsuranceValue);
      vJsonObjOptions_Invoice:= TJSONObject.Create;
      vJsonObjOptions_Invoice.AddPair('key', AChaveNota);
      vJsonObjOptions.AddPair('invoice', vJsonObjOptions_Invoice);
      JsonObj.AddPair('service', AIdTransportadora);
      JsonObj.AddPair('from', vJsonObjFrom);
      JsonObj.AddPair('to', vJsonObjTo);
      JsonObj.AddPair('products', JsonProdutos);
      JsonObj.AddPair('volumes', JsonVolumes);
      JsonObj.AddPair('options', vJsonObjOptions);
      var vjsonstr: TStringStream;
      vjsonstr:= TStringStream.Create(JsonObj.ToString);
      try
        vjsonstr.SaveToFile('C:\Users\Master\Desktop\json.txt');
      finally
        vjsonstr.Free;
      end;
      vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
                .Timeout(C_TIMEOUT)
                .Resource('api/v2/me/cart')
                .ContentType('application/json')
                .AcceptEncoding('application/json')
                .AddHeader('Authorization', 'Bearer token')
                .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
                .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
                .AddBody(JsonObj.ToString)
                .Post;
      if vResp.StatusCode <> 201 then
        raise Exception.Create(vResp.Content)
      else begin
        FMelhorEnvioBase.Sucesso(True);
        FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');
        Result:= vResp.Content;
      end;
    finally
      JsonObj.Free;
    end;
  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;
function TMelhorEnvio.Base: iMelhorEnvioBase<iMelhorEnvio>;
begin
  Result:= FMelhorEnvioBase;
end;

procedure TMelhorEnvio.CompraFrete(AIdList: TDataset);
var
  vResp: IResponse;
  vJsonObject: TJSONObject;
  vJsonOrders: TJSONArray;
begin
  try
    vJsonObject:= TJSONObject.Create;
    try
      AIdList.First;
      vJsonOrders:= TJSONArray.Create;
      while not AIdList.Eof do begin
        vJsonOrders.Add(AIdList.FieldByName('ID_ETIQUETA').AsString);
        AIdList.Next;
      end;
      vJsonObject.AddPair('orders', vJsonOrders);
      vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
                .Timeout(C_TIMEOUT)
                .Resource('api/v2/me/shipment/checkout')
                .ContentType('application/json')
                .AcceptEncoding('application/json')
                .AddHeader('Authorization', 'Bearer token')
                .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
                .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
                .AddBody(vJsonObject.ToString)
                .Post;

      if vResp.StatusCode <> 200 then
        raise Exception.Create(vResp.Content);

      FMelhorEnvioBase.Sucesso(True);
      FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');
    finally
      vJsonObject.Free;
    end;
  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

function TMelhorEnvio.ListaItensCarrinho(ADataset: TDataset): iMelhorEnvio;
var
  vResp: IResponse;
  JSONObject, Item, ServiceObj, ToObj: TJSONObject;
  JSONArray: TJSONArray;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('api/v2/me/cart')
              .ContentType('application/json')
              .AcceptEncoding('application/json')
              .AddHeader('Authorization', 'Bearer token')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
              .Get;

    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content);

    FMelhorEnvioBase.Sucesso(True);
    FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');

    JSONObject := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
    try
      JSONArray := JSONObject.GetValue<TJSONArray>('data');
      if Assigned(JSONArray) then begin
        for var I: integer := 0 to JSONArray.Count - 1 do begin
          ADataset.Append;
          ADataset.FieldByName('ID').AsInteger:= I + 1;
          Item := JSONArray.Items[I] as TJSONObject;

          ADataset.FieldByName('ID_ETIQUETA').AsString:= Item.GetValue<string>('id');

          ADataset.FieldByName('PRECO').AsCurrency:= Item.GetValue<Double>('price');

          ServiceObj := Item.GetValue<TJSONObject>('service');
          if Assigned(ServiceObj) then
            ADataset.FieldByName('SERVICO_NOME').AsString:= ServiceObj.GetValue<string>('name');

          ToObj := Item.GetValue<TJSONObject>('to');
          if Assigned(ToObj) then
            ADataset.FieldByName('CLIENTE_NOME').AsString:= ToObj.GetValue<string>('name');
          ADataset.Post;
        end;
      end;
    finally
      JSONObject.Free;
    end;

  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

function TMelhorEnvio.RemoveItemCarrinho(AOrderID: String): iMelhorEnvio;
var
  vResp: IResponse;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('api/v2/me/cart/' + AOrderID)
              .ContentType('application/json')
              .AcceptEncoding('application/json')
              .AddHeader('Authorization', 'Bearer token')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
              .Delete;

    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content);

    FMelhorEnvioBase.Sucesso(True);
    FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');

  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

function TMelhorEnvio.SaldoUsuario: Currency;
var
  vResp: IResponse;
  vJSONObject: TJSONObject;
  vReserved, vDebts: Currency;
begin
  Result:= 0;
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('api/v2/me/balance')
              .ContentType('application/json')
              .AcceptEncoding('application/json')
              .AddHeader('Authorization', 'Bearer token')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
              .Get;

    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content);

    FMelhorEnvioBase.Sucesso(True);
    FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');

    vJSONObject:= TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
    try
      vJSONObject.TryGetValue<Currency>('reserved', vReserved);
      vJSONObject.TryGetValue<Currency>('debts', vDebts);
      if vJSONObject.TryGetValue<Currency>('balance', Result) then begin
        Result:= Result - vReserved - vDebts;
        Exit;
      end;
    finally
      vJSONObject.Free;
    end;
  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

procedure TMelhorEnvio.GeraEtiqueta(AIdOrder: String);
var
  vResp: IResponse;
  vJsonObject: TJSONObject;
  vJsonOrders: TJSONArray;
begin
  try
    vJsonObject:= TJSONObject.Create;
    try
      vJsonOrders:= TJSONArray.Create;
      vJsonOrders.Add(AIdOrder);

      vJsonObject.AddPair('orders', vJsonOrders);
      vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
                .Timeout(C_TIMEOUT)
                .Resource('api/v2/me/shipment/generate')
                .ContentType('application/json')
                .AcceptEncoding('application/json')
                .AddHeader('Authorization', 'Bearer token')
                .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
                .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
                .AddBody(vJsonObject.ToString)
                .Post;

      if vResp.StatusCode <> 200 then
        raise Exception.Create(vResp.Content)
      else begin
        FMelhorEnvioBase.Sucesso(True);
        FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');
      end;
    finally
      vJsonObject.Free;
    end;
  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

procedure TMelhorEnvio.ImprimeEtiquetaArquivo(AIdOrder: String; AFile: TStream);
var
  vResp: IResponse;
begin
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('api/v2/me/imprimir/pdf/' + AIdOrder)
              .ContentType('application/json')
              .AcceptEncoding('application/json')
              .AddHeader('Authorization', 'Bearer token')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
              .Get;
    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content)
    else begin
      AFile.WriteBuffer(vResp.RawBytes[0], Length(vResp.RawBytes));
      AFile.Position:= 0;
      FMelhorEnvioBase.Sucesso(True);
      FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');
    end;
  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

function TMelhorEnvio.ListarEtiquetas(AStatus: String; ADataset: TDataset): iMelhorEnvio;
var
  vResp: IResponse;
  JSONObject, Item, ServiceObj, ToObj: TJSONObject;
  JSONArray: TJSONArray;
  count: Integer;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('api/v2/me/orders')
              .ContentType('application/json')
              .AcceptEncoding('application/json')
              .AddHeader('Authorization', 'Bearer token')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .AddParam('status', AStatus)
              .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
              .Get;

    if vResp.StatusCode <> 200 then
      raise Exception.Create(vResp.Content);

    FMelhorEnvioBase.Sucesso(True);
    FMelhorEnvioBase.Mensagem('Consulta realizada com sucesso!');

    count:= ADataset.RecordCount;

    JSONObject := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
    try
      JSONArray := JSONObject.GetValue<TJSONArray>('data');
      if Assigned(JSONArray) then begin
        for var I: integer := 0 to JSONArray.Count - 1 do begin
          ADataset.Append;
          if count > 0 then begin
            ADataset.FieldByName('ID').AsInteger:= count + 1;
            inc(count);
          end else
            ADataset.FieldByName('ID').AsInteger:= I + 1;
          Item := JSONArray.Items[I] as TJSONObject;

          ADataset.FieldByName('ID_ETIQUETA').AsString:= Item.GetValue<string>('id');
          ADataset.FieldByName('PROTOCOL').AsString:= Item.GetValue<string>('protocol');
          ADataset.FieldByName('STATUS').AsString:= Item.GetValue<string>('status');

          ToObj := Item.GetValue<TJSONObject>('to');
          if Assigned(ToObj) then
            ADataset.FieldByName('CLIENTE_NOME').AsString:= ToObj.GetValue<string>('name');
          ADataset.Post;
        end;
      end;
    finally
      JSONObject.Free;
    end;

  except
    on E:Exception do begin
      FMelhorEnvioBase.Sucesso(False);
      FMelhorEnvioBase.Mensagem(E.Message);
    end;
  end;
end;

end.
