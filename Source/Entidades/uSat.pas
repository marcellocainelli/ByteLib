unit uSat;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TSat = class(TInterfacedObject, iEntidade)
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

{ TSat }

constructor TSat.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('');
  InicializaDataSource;
end;

destructor TSat.Destroy;
begin
  inherited;
end;

class function TSat.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TSat.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TSat.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= 'Select SERIE as CODIGO, SERIE, MARCA, MODELO, null as INDICE From SAT_CADASTRO where STATUS = ''A'' and COD_FILIAL = :CodFilial';
    1:
    begin
      vTextoSQL:= 'Select * From SAT_CADASTRO where COD_FILIAL = :CodFilial ';
      If not FEntidadeBase.Inativos then
        vTextoSQL:= vTextoSQL + ' and STATUS = ''A'' ';
    end;
  End;
  FEntidadeBase.Iquery.IndexFieldNames('SERIE');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TSat.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From SAT_CADASTRO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TSat.ModificaDisplayCampos;
begin

end;

function TSat.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
