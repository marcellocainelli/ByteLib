unit uPosto_MvTanque;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPosto_MvTanque = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure MyCalcFields(sender: TDataSet);
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

{ TPosto_MvTanque }

constructor TPosto_MvTanque.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select * From MVTANQUE Where COD_FILIAL = :pCod_Filial ' +
    ' and COD_CAIXA = :mCod_Caixa and DATA = :mData ' +
    ' Order by COD_BOMBA');
   InicializaDataSource;
end;

destructor TPosto_MvTanque.Destroy;
begin
  inherited;
end;

class function TPosto_MvTanque.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_MvTanque.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_MvTanque.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['Qtdd_Aferida', 'Qtdd_Vendida', 'Qtdd_Diferenca'], [ftFloat, ftFloat, ftFloat]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TPosto_MvTanque.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From MVTANQUE Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_MvTanque.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('afericoes')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('qtdd_aferida')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('qtdd_vendida')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('qtdd_diferenca')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
end;

procedure TPosto_MvTanque.MyCalcFields(sender: TDataSet);
begin
  FEntidadeBase.Iquery.DataSet.FieldByName('Qtdd_Aferida').AsFloat:=
    RoundABNT(FEntidadeBase.Iquery.DataSet.FieldByName('LEIT_FIM').AsFloat - FEntidadeBase.Iquery.DataSet.FieldByName('LEIT_INICIO').AsFloat, -2);
  FEntidadeBase.Iquery.DataSet.FieldByName('Qtdd_Diferenca').AsFloat:=
    RoundABNT(FEntidadeBase.Iquery.DataSet.FieldByName('Qtdd_Aferida').AsFloat - FEntidadeBase.Iquery.DataSet.FieldByName('Qtdd_Vendida').AsFloat - FEntidadeBase.Iquery.DataSet.FieldByName('AFERICOES').AsFloat, -2);
end;

function TPosto_MvTanque.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
