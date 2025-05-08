unit Byte.Controller.MelhorEnvio_v1;

interface

uses
  System.SysUtils, System.Classes, System.JSON, RESTRequest4D, Model.Entidade.Interfaces, uEntidade,
  Byte.Lib, System.DateUtils, Data.DB, System.Generics.Collections;

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


  iMelhorEnvioBase<T> = interface
    ['{F6F5167E-917F-4CCC-9CDC-BAA373315934}']
    function Sucesso: Boolean; overload;
    procedure Sucesso(AValue: Boolean); overload;
    function Mensagem: String; overload;
    procedure Mensagem(AValue: String); overload;
    function ClientID(AValue: String): iMelhorEnvioBase<T>; overload;
    function ClientID: String; overload;
    function SecretKey(AValue: String): iMelhorEnvioBase<T>; overload;
    function SecretKey: String; overload;
    function Code(AValue: String): iMelhorEnvioBase<T>;
    function Authorize: String;
    function RefreshToken: iMelhorEnvioBase<T>;
    function RefreshTokenToString: String;
    function AccessToken: iMelhorEnvioBase<T>;
    function AccessTokenToString: String;
    function &End : T;
  end;

  TMelhorEnvioBase<T: IInterface> = class(TInterfacedObject, iMelhorEnvioBase<T>)
  private
    [Weak]
    FParent: T;
    FMensagem: String;
    FSucesso: Boolean;
    FSecretKey, FClientID, FCode, FRefreshToken, FAccessToken: String;
    FDateToken, FDateRefreshToken: TDate;
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
    function ClientID(AValue: String): iMelhorEnvioBase<T>; overload;
    function ClientID: String; overload;
    function SecretKey(AValue: String): iMelhorEnvioBase<T>; overload;
    function SecretKey: String; overload;
    function Code(AValue: String): iMelhorEnvioBase<T>;
    function Authorize: String;
    function RefreshToken: iMelhorEnvioBase<T>;
    function RefreshTokenToString: String;
    function AccessToken: iMelhorEnvioBase<T>;
    function AccessTokenToString: String;
  end;

  iMelhorEnvio = interface
    ['{4F12FCF5-F635-44B7-9625-C22CAD6F882B}']
    function Sucesso: Boolean;
    function Mensagem: String;
    function AddProduct(AProduct: TProduct): iMelhorEnvio;
    function CalculoFrete(AFrom, ATo: String): String;
  end;

  TMelhorEnvio = class(TInterfacedObject, iMelhorEnvio)
    private
      FMelhorEnvioBase: iMelhorEnvioBase<iMelhorEnvio>;
      FProdutos: TObjectList<TProduct>;
      constructor Create;
      destructor Destroy; override;
    public
      class function New: iMelhorEnvio;
      function Sucesso: Boolean;
      function Mensagem: String;
      function AddProduct(AProduct: TProduct): iMelhorEnvio;
      function CalculoFrete(AFrom, ATo: String): String;
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
  VerificarERenovarTokens;
end;

destructor TMelhorEnvioBase<T>.Destroy;
begin

  inherited;
end;

function TMelhorEnvioBase<T>.ClientID(AValue: String): iMelhorEnvioBase<T>;
begin
  Result:= Self;
  FClientID:= AValue;
end;

function TMelhorEnvioBase<T>.ClientID: String;
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

function TMelhorEnvioBase<T>.AccessTokenToString: String;
begin
  Result:= FAccessToken;
end;

function TMelhorEnvioBase<T>.Authorize: String;
begin
  Result:=
    C_URL_SANDBOX +
    Format('oauth/authorize?%s=%s&%s=%s&%s=%s&%s=%s',
      ['client_id', FClientID,
       'redirect_uri', C_REDIRECT,
       'response_type', 'code',
       'scope', 'shipping-calculate shipping-companies shipping-generate shipping-print ecommerce-shipping shipping-checkout'
      ]
    );
end;

function TMelhorEnvioBase<T>.RefreshToken: iMelhorEnvioBase<T>;
var
  vResp: IResponse;
begin
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('oauth/token')
              .ContentType('application/json')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .AddParam('grant_type', 'authorization_code')
              .AddParam('client_id', FClientID)
              .AddParam('client_secret', FSecretKey)
              .AddParam('redirect_uri', C_REDIRECT)
              .AddParam('code', FCode)
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
begin
  try
    vResp:= TRequest.New.BaseURL(C_URL_SANDBOX)
              .Timeout(C_TIMEOUT)
              .Resource('oauth/token')
              .ContentType('application/json')
              .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
              .AddParam('grant_type', 'refresh_token')
              .AddParam('client_id', FClientID)
              .AddParam('client_secret', FSecretKey)
              .AddParam('refresh_token', FRefreshToken)
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
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pRefreshToken', TLib.Crypt(FRefreshToken, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL'), ftString);
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pREFRESH_TOKEN_EXPIRA', FDateRefreshToken, ftDate);
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pToken', TLib.Crypt(FAccessToken, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL'), ftString);
      vSalvaToken.EntidadeBase.Iquery.AddParametro('pTOKEN_EXPIRA', FDateToken, ftDate);
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

  FCode:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('CODE').AsString;//TLib.Crypt(vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('CODE').AsString, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL');
  FRefreshToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('REFRESH_TOKEN').AsString;//TLib.Crypt(vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('REFRESH_TOKEN').AsString, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL');
  FAccessToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('TOKEN').AsString;//TLib.Crypt(vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('TOKEN').AsString, 'xg89aQyUj7g3P3JWKQRS30ZjehtlFL');
  FDateToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('TOKEN_EXPIRA').AsDateTime;
  FDateRefreshToken:= vConfigMelhorEnvio.DtSrc.DataSet.FieldByName('REFRESH_TOKEN_EXPIRA').AsDateTime;
end;

{ TMelhorEnvio }

class function TMelhorEnvio.New: iMelhorEnvio;
begin
  Result:= Self.Create;
end;

constructor TMelhorEnvio.Create;
begin
  FMelhorEnvioBase:= TMelhorEnvioBase<iMelhorEnvio>.New(Self);
  FProdutos := TObjectList<TProduct>.Create;
end;

destructor TMelhorEnvio.Destroy;
begin
  FProdutos.Free;
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
                .Resource('oauth/token')
                .ContentType('application/json')
                .AddHeader('User-Agent', 'Doutor Byte(adm@doutorbytesistemas.com.br)')
                .TokenBearer(FMelhorEnvioBase.AccessTokenToString)
                .AddBody(JsonObj.ToString)
                .Post;

      if vResp.StatusCode <> 200 then
        raise Exception.Create(vResp.Content)
      else
        Result:= vResp.Content;
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

end.
