import streamlit as st
import torch
import functions
from transformers import pipeline
from transformers import AutoTokenizer

MODEL_ID = "PY007/TinyLlama-1.1B-intermediate-step-715k-1.5T"
HUGGING_FACE_TOKEN = ""
OPEN_AI_TOKEN = ""  # optional, wenn OpenAI API genutzt werden soll.
USE_HUGGING_FACE = True
USE_CONTEXT = False

tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
generator = pipeline("text-generation",
                     model=MODEL_ID,
                     torch_dtype=torch.float16,
                     device_map="auto",
                     token=HUGGING_FACE_TOKEN
                     )

# Logo anzeigen
st.image('akad_main_logo.png', width=150)

st.title("KOM 81 - Q&A Bot for personal support")
st.sidebar.button('🚮 Clear Chat', on_click=functions.clear_chat)

# ChatHistorie initialsieren:
if "messages" not in st.session_state.keys():
    st.session_state.messages = [{"role": "assistant", "content": "How can I help you?"}]

# ChatHistorie wiedergeben, wenn der Bot neu gestartet wurde:
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Auf User Input reagieren:
prompt = st.chat_input("Your input here...")
if prompt:
    # Prompt in die Message-Historie mit aufnehmen.
    st.session_state.messages.append({"role": "user", "content": prompt})

    # Im Chatverlauf die Anfrage des users schreiben:
    with st.chat_message("user"):
        st.write(prompt)

    # Generate a new response if last message is not from assistant
    if st.session_state.messages[-1]["role"] != "assistant":
        # Kontext der Antwort des Assistenten:
        with st.chat_message("assistant"):
            # Platzhalter für die Dauer, die das Modell nach der Antwort sucht...
            with st.spinner("I'm working on you response... 😉"):
                # Generierung einer Antwort unter Berücksichtigung der gesamten Chat-Historie:
                if USE_HUGGING_FACE:
                    response = functions.generate_response_small_model(generator, tokenizer, USE_CONTEXT)
                else:
                    response = functions.generate_response_gpt(OPEN_AI_TOKEN)

                placeholder = st.empty()
                placeholder.write(response)
        message = {"role": "assistant", "content": response}
        st.session_state.messages.append(message)
