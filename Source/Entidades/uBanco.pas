unit uBanco;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TBanco = class(TInterfacedObject, iEntidade)
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

{ TBanco }

constructor TBanco.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From BANCO Where CONTA = :mConta and DATA > :pDt_Inicio ');
end;

destructor TBanco.Destroy;
begin
  inherited;
end;

class function TBanco.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TBanco.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TBanco.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSql:= FEntidadeBase.TextoSql + 'Order by DATA, SEQ';
    1: vTextoSql:= FEntidadeBase.TextoSql + 'and Coalesce(PENDENTE,'' '') = '' '' Order by DATA, SEQ';
    2: vTextoSql:= FEntidadeBase.TextoSql + 'and Coalesce(PENDENTE,'' '') = ''P'' Order by DATA, SEQ';
  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TBanco.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TBanco.ModificaDisplayCampos;
begin

end;

end.
