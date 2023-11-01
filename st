# Adicionar colunas para os widgets
c1, c2 = st.columns(2)

# Widget para seleção da data mínima
min_date = c1.date_input("Data Início", min_value=df['date'].min(), max_value=df['date'].max())

# Widget para seleção da data máxima
max_date = c2.date_input("Data Fim", min_value=df['date'].min(), max_value=df['date'].max())

# Fazer o filtro com base nas datas selecionadas
if min_date <= max_date:
    filtered_df = df[(df['date'] >= min_date) & (df['date'] <= max_date)]
else:
    st.error('Erro: A data de início não pode ser maior que a data de fim.')

# Exibir o DataFrame filtrado
st.dataframe(filtered_df)


-------------------------------------------------------------------------------------


# Importar a biblioteca Streamlit
import streamlit as st
# Importar biblioteca Snowpark
from snowflake.snowpark.context import get_active_session
import pandas as pd

# Criar uma sessão
session = get_active_session()

# Criar Snowpark DataFrames que carregue os dados da tabela stg_log_produto
def load_data(session):
    # Carregar dados da tabela stg_log_produto
    snow_df_lineitem = session.table("SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM")
    snow_df_lineitem_total = snow_df_lineitem.select('L_RECEIPTDATE', 'L_EXTENDEDPRICE').sort('L_RECEIPTDATE', ascending=False).limit(1)
    snow_df_lineitem_limit = snow_df_lineitem.select('L_RECEIPTDATE', 'L_EXTENDEDPRICE').sort('L_RECEIPTDATE', ascending=False).limit(100)
    
    # Converter Snowpark DataFrame para Pandas DataFrame para uso no Streamlit
    pd_df_lineitem = snow_df_lineitem.to_pandas()
    pd_df_lineitem_total = snow_df_lineitem_total.to_pandas()
    pd_df_lineitem_limit = snow_df_lineitem_limit.to_pandas()

    return pd_df_lineitem, pd_df_lineitem_total, pd_df_lineitem_limit

def main():
    # Adicionar header e um subheader
    st.header("Streamlit")
    st.subheader("App")
    
    # Carregar e processar os dados
    pd_df_lineitem, pd_df_lineitem_total, pd_df_lineitem_limit = load_data(session)
        
    # Extrair o valor numérico da coluna 'L_EXTENDEDPRICE'
    total_value = pd_df_lineitem_total['L_EXTENDEDPRICE'].iloc[0]

    # Criar um card com o valor
    st.metric("Total", total_value)

    # Título do aplicativo
    st.title("Gráfico de Data x Preço")
    
    # Gráfico de linha usando Plotly Express
    st.line_chart(pd_df_lineitem_limit, use_container_width=True, x='L_RECEIPTDATE', y='L_EXTENDEDPRICE')
   
if __name__ == "__main__":
    main()
