Wie die app genutzt werden kann:
- 1. Schritt: Installation der requirements -> pip install -r requirements.txt
- 2. Schritt: Ich wusste ehrlich gesagt nicht ob wir jetzt OpenAI verwenden durften oder Hugging Face sollten. Deswegen
              kann man eine Weiche "USE_HUGGING_FACE" setzen. Ist USE_HUGGING_FACE = True dann wird ein kleines Modell
              von Hugging Face verwendet, hierbei sollte auch USE_CONTEXT am besten auf False gesetzt werden.
              Ist OpenAi erlaubt, so kann USE_HUGGING_FACE auf False gesetzt werden, dann wird das in der Vorlesung
              vorstellte Modell GPT-3.5 verwendet USE_CONTEXT wird automatisch mit True gewertet.
- 3. Schritt: Entsprechenden TOKENs pflegen.
- 4. Schritt: run.cmd laufen lassen
-- Dabei wird zunächst etwas Zeit für den Download des Modells benötigt (ca. 4 GB)
-- Falls ein anderes Q&A geeignetes Modell bereits im Huggingface-Hub Cache enthalten ist, kann gern die MODEL_ID
   ersetzt werden. Das spart Zeit.
- 5. Schritt... drauf los chatten...
  Falls die Antwortlänge nicht ausreicht, kann der Wert von RESPONSE_LIMIT hochgesetzt werden.
  Zeitweise (sporadisch) kam es bei mir zu folgendem Fehler, den ich selbst nicht beheben kann, hier einfach erneut starten
  RuntimeError: "addmm_impl_cpu_" not implemented for 'Half'

Ich habe das Modell mit der ID "PY007/TinyLlama-1.1B-intermediate-step-715k-1.5T" ein bischen getestet.
Da es sich um ein recht kleines Modell handelt, sollten die Fragen entsprechend direkt gestellt werden.
Am besten hat sich herausgestellt, dass die folgenden Fragestellungen sich in englischam besten eignen:
- I want to know ...
- I like to know ...
- I wanted to ask ...

Hinweis: mit diesem kleinen Modell ist eine Berücksichtigung des bisherigen Chatverlaufs nicht möglich.
Im Code ist es jedoch vorgesehen, wird aber nicht benutzt = USE_CONTEXT = False

Beispielsätze, die gut funktioniert haben mit dem oben genannten Modell:
- I would like to know where Germany is located.
- I wanted to know how many regions are in Germany.
- I would like to know in which city the Eiffel Tower is.
- I want to know who Donald Trump is.
