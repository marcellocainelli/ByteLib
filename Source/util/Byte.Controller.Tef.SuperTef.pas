unit Byte.Controller.Tef.SuperTef;
interface
uses
  System.Classes, System.SysUtils, System.JSon, System.StrUtils, RESTRequest4D, Byte.Json, DTSuperTEF;
const
  C_MaxConsultas = 30;
  C_TIMEOUT = 30000;
  C_BASE_URL = 'https://api.supertef.com.br/api/';
  C_TOKEN = '1ndbg64nd5deobg3416ofn3gca4c62dgof2efca1aeo1d6fb4fg3c51`35bfcngo';
type
  tpCobStatus= (cobAberta, cobCancelada, cobPaga, cobNaoExiste);
  iSuperTef = interface
    ['{AC24B481-EE86-4B3E-A6FF-A51D89622D0E}']
    function NumSerialPos(AValue: String): iSuperTef;
    function Token(AValue: String): iSuperTef;
    function ChaveCliente(AValue: String): iSuperTef;
    function IDCobranca(AValue: String): iSuperTef;
    function IDPagamento(AValue: String): iSuperTef;
    function QtParcelas(AValue: String): iSuperTef;
    function Cpf(AValue: String): iSuperTef;
    function Nome(AValue: String): iSuperTef;
    function Amount(AValue: Currency): iSuperTef;
    function CobStatus: tpCobStatus;
    function Auth: string;
    function CriarPagamento: iSuperTef; //nova venda
    function CancelaPagamento: string; //exclui venda
    function GetStatus: iSuperTef;
    function QtdConsultas: integer; overload;
    function QtdMaxConsultas: integer;
    procedure QtdConsultas(Value: integer); overload;
  end;
  TSuperTef = class(TInterfacedObject, iSuperTef)
  private
    FNumSerialPos, FIDCobranca, FIDPagamento, FQtParcelas, FCpf, FNome, FToken, FChaveCliente: String;
    FAmount: Currency;
    FCobStatus: tpCobStatus;
    FQtdConsultas: Integer;
    FPaymentId: String;
    DTSuperTEF1: TDTSuperTEF;
    constructor Create;
    destructor Destroy; override;
  public
    class function New: iSuperTef;
    function NumSerialPos(AValue: String): iSuperTef;
    function Token(AValue: String): iSuperTef;
    function ChaveCliente(AValue: String): iSuperTef;
    function IDCobranca(AValue: String): iSuperTef;
    function IDPagamento(AValue: String): iSuperTef;
    function QtParcelas(AValue: String): iSuperTef;
    function Cpf(AValue: String): iSuperTef;
    function Nome(AValue: String): iSuperTef;
    function Amount(AValue: Currency): iSuperTef;
    function CobStatus: tpCobStatus;
    function Auth: string;
    function CriarPagamento: iSuperTef;
    function CancelaPagamento: string;
    function GetStatus: iSuperTef;
    function QtdConsultas: integer; overload;
    function QtdMaxConsultas: integer;
    procedure QtdConsultas(Value: integer); overload;
  end;
implementation

{ TTokenAws }

class function TSuperTef.New: iSuperTef;
begin
  Result:= Self.Create;
end;

constructor TSuperTef.Create;
begin
  FNumSerialPos:= '';
  FIDCobranca:= '';
  FIDPagamento:= '1';
  FQtParcelas:= '1';
  FCpf:= '';
  FNome:= '';
  FAmount:= 0.00;
  FQtdConsultas:= 0;
  DTSuperTEF1:= TDTSuperTEF.Create(nil);
end;

destructor TSuperTef.Destroy;
begin
  FreeAndNil(DTSuperTEF1);
  inherited;
end;

function TSuperTef.Amount(AValue: Currency): iSuperTef;
begin
  Result:= Self;
  FAmount:= AValue;
end;

function TSuperTef.ChaveCliente(AValue: String): iSuperTef;
begin
  Result:= Self;
  FChaveCliente:= AValue;
end;

function TSuperTef.CobStatus: tpCobStatus;
begin
  Result:= FCobStatus;
end;

function TSuperTef.Cpf(AValue: String): iSuperTef;
begin
  Result:= Self;
  FCpf:= AValue;
end;

function TSuperTef.IDCobranca(AValue: String): iSuperTef;
begin
  Result:= Self;
  FIDCobranca:= AValue;
end;

function TSuperTef.IDPagamento(AValue: String): iSuperTef;
begin
  Result:= Self;
  FIDPagamento:= AValue;
end;

function TSuperTef.Nome(AValue: String): iSuperTef;
begin
  Result:= Self;
  FNome:= AValue;
end;

function TSuperTef.NumSerialPos(AValue: String): iSuperTef;
begin
  Result:= Self;
  FNumSerialPos:= AValue;
end;

function TSuperTef.QtParcelas(AValue: String): iSuperTef;
begin
  Result:= Self;
  FQtParcelas:= AValue;
end;

function TSuperTef.Token(AValue: String): iSuperTef;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TSuperTef.Auth: string;
begin
  Result:= FToken;
end;

function TSuperTef.CriarPagamento: iSuperTef;
var
  Pagamento: TPagamento;
begin
  Result:= Self;
  DTSuperTEF1.Token := Auth;

  try
    Pagamento := DTSuperTEF1.CriarPagamento(
      FChaveCliente,
      StrToIntDef(FNumSerialPos, 0),
      FIDPagamento,
      StrToIntDef(FQTParcelas, 1),
      1,
      FAmount,
      FIDCobranca,
      FNome
    );

    try
      // Salva o Unique ID do pagamento criado para uso posterior
      FPaymentId := Pagamento.PaymentUniqueid.ToString;
    finally
      Pagamento.Free;
    end;
  except
    on E: Exception do begin
      FCobStatus:= cobNaoExiste;
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TSuperTef.CancelaPagamento: string;
var
  Response: TRejeitarPagamentoResponse;
begin
  Result:= '';
  DTSuperTEF1.Token := Auth;

  try
    Response := DTSuperTEF1.RejeitarPagamento(StrToIntDef(FPaymentId, 0));
    try
      if Response.Status then
        FCobStatus:= cobCancelada;
    finally
      Response.Free;
    end;
  except
    on E: Exception do begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TSuperTef.GetStatus: iSuperTef;
var
  Pagamento: TPagamento;
begin
  Result:= Self;

  DTSuperTEF1.Token := Auth;
  try
    Pagamento := DTSuperTEF1.DetalharPagamento(StrToIntDef(FPaymentId, 0));
    try
      case AnsiIndexStr(Pagamento.PaymentMessage, ['Pago', 'Cancelado/erro']) of
        0: FCobStatus:= cobPaga;
        1: FCobStatus:= cobCancelada;
      end;
    finally
      Pagamento.Free;
    end;
  except
    on E: Exception do begin
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TSuperTef.QtdConsultas: integer;
begin
  Result:= FQtdConsultas;
end;
procedure TSuperTef.QtdConsultas(Value: integer);
begin
  FQtdConsultas:= Value;
end;
function TSuperTef.QtdMaxConsultas: integer;
begin
  Result:= C_MaxConsultas;
end;

end.
