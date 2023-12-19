import streamlit as st
import requests

PRE_INSTRUCTION = "Act as a helpful Question and Answer Supporter, your focus is on providing answers without " \
                  "assuming the position of a user or pretending to be one. Simple try to answer the last question."
RESPONSE_LIMIT = 250


# Funktion zum Löschen der Historie > Bessere Benutzerfreundlichkeit
def clear_chat():
    st.session_state.messages = [{"role": "assistant", "content": "How may I assist you today?"}]


def generate_response_gpt(api_key):
    instruction = PRE_INSTRUCTION

    for message in st.session_state.messages[1:]:
        if message is not None:
            if message["role"] == "user":
                instruction += "User: " + message["content"] + "\n\n"
            elif message["role"] == "assistant":
                instruction += "Assistent: " + message["content"] + "\n\n"

    print(f"Kontext für das Modell: {instruction}")

    url = "https://api.openai.com/v1/chat/completions"
    headers = {"Content-Type": "application/json","Authorization":"Bearer " + api_key}
    data = {
      "model": "gpt-3.5-turbo",
      "messages": [{"role": "user", "content": instruction}],
      "max_tokens": 512,
      "temperature": 1,
      "top_p": 1,
      "n": 1,
      "presence_penalty": 0,
      "frequency_penalty": 0
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code != 200:
        print("Status Code", response.status_code)
        response = response.text
    else:
        j = response.json()
        response = j["choices"][0]["message"]["content"]

    print(f"Generierte Antwort nach Modifikation: {response}")
    return response


# Funktion zum Generieren einer Antwort
def generate_response_small_model(generator, tokenizer, use_context):
    # Wenn ein mächtigeres Modell als das hier vorgesehene verwendet wird, dann kann USE_CONTEXT gern auf
    # True gesetzt werden, damit kann der Bot die Historie mit berücksichtigen.
    if use_context:
        instruction = PRE_INSTRUCTION

        if len(st.session_state.messages) > 4:
            end_index = -3
        else:
            end_index = None
        for message in st.session_state.messages[1:end_index]:
            if message is not None:
                if message["role"] == "user":
                    instruction += message["content"] + "\n\n"
                elif message["role"] == "assistant":
                    instruction += message["content"] + "\n\n"
    else:
        instruction = st.session_state.messages[-1]["content"]

    print(f"Kontext für das Modell: {instruction}")
    response = generator(
        instruction,
        do_sample=True,
        top_k=10,
        num_return_sequences=1,
        repetition_penalty=1,
        eos_token_id=tokenizer.eos_token_id,
        max_length=len(instruction) + RESPONSE_LIMIT,
    )[0]['generated_text']

    # "Echos" in der Antwort entfernen, bei use_context = True wird auch noch die PRE_INSTRUCTION entfernt.
    response = response.replace(PRE_INSTRUCTION, '')
    for message in st.session_state.messages:
        if message["role"] == "user":
            response = response.replace(message['content'], '')
        elif message["role"] == "assistant":
            response = response.replace(message['content'], '')

    # Wenn die Länge ger Antwort mehr als 100 Zeichen (Limit) beträgt, dann sollten die letzten drei Zeichen "..." sein
    if len(response) > 100:
        response = response[0:RESPONSE_LIMIT-4] + "..."

    print(f"Generierte Antwort nach Modifikation: {response}")

    return response
