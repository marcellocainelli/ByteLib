unit uVasilhame_Entrada;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;
Type
  TVasilhameEntrada = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure OnNewRecord(DataSet: TDataSet);
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

{ TVasilhameEntrada }

constructor TVasilhameEntrada.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From VASILHAME_ENTRADA ');
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TVasilhameEntrada.Destroy;
begin
  inherited;
end;

class function TVasilhameEntrada.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TVasilhameEntrada.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TVasilhameEntrada.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' Where ID = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TVasilhameEntrada.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where ID = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TVasilhameEntrada.ModificaDisplayCampos;
begin

end;

procedure TVasilhameEntrada.OnNewRecord(DataSet: TDataSet);
begin

end;

function TVasilhameEntrada.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
