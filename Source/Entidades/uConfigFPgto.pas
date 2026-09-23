unit uConfigFPgto;

interface

uses
  uEntidadeBase,
  Data.DB,
  Model.Entidade.Interfaces,
  System.SysUtils;

Type
  TConfigFPagto = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;

implementation

{ TConfigFPagto }

constructor TConfigFPagto.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CONFIG_FORMAPAGAMENTO ');
  InicializaDataSource;
end;

destructor TConfigFPagto.Destroy;
begin
  inherited;
end;

class function TConfigFPagto.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfigFPagto.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfigFPagto.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSql:= FEntidadeBase.TextoSql + 'where id = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
end;

function TConfigFPagto.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('select * from CONFIG_FORMAPAGAMENTO Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfigFPagto.ModificaDisplayCampos;
begin

end;

function TConfigFPagto.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
