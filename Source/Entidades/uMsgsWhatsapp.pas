unit uMsgsWhatsapp;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TMsgsWhatsapp = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TMsgsWhatsapp }

constructor TMsgsWhatsapp.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From MSGS_WHATSAPP');
end;

destructor TMsgsWhatsapp.Destroy;
begin
  inherited;
end;

class function TMsgsWhatsapp.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TMsgsWhatsapp.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TMsgsWhatsapp.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= '';

  if FEntidadeBase.RegraPesquisa = 'Contendo' then
      FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + ' where STATUS = :Parametro'; //consulta por status
  end;

  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TMsgsWhatsapp.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;

  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + 'CODIGO = :Parametro');

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TMsgsWhatsapp.ModificaDisplayCampos;
begin

end;

end.
