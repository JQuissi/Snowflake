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
