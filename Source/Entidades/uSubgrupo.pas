unit uSubgrupo;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TSubgrupo = class(TInterfacedObject, iEntidade)
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

uses
  uEntidadeBase;

{ TSubgrupo }

constructor TSubgrupo.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select S.*, 0 as INDICE from SUBGRUPOS S');

  InicializaDataSource;
end;

destructor TSubgrupo.Destroy;
begin
  inherited;
end;

class function TSubgrupo.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TSubgrupo.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TSubgrupo.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TSubgrupo.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TSubgrupo.ModificaDisplayCampos;
begin

end;

function TSubgrupo.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
