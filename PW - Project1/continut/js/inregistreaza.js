const sub_form = async (ev) => {
    ev.preventDefault();
    const el = ev.target;
    const inputs = el.querySelectorAll("input");
    const req = {};

    for (const input of inputs) {
        const id_name = input.id;
        const id_val = input.value;
        if (!id_val) {
            alert(`Valoarea [${id_name}] nu poate să fie goală!`);
            return;
        }
        req[id_name] = id_val;
    }

    try {
        const res = await fetch("resurse/utilizatori.json");
        const text = await res.text();

        let utilizatori = [];
        try {
            utilizatori = JSON.parse(text);
        } catch (err) {
            utilizatori = [];
        }

        utilizatori.push(req);

        const postRes = await fetch("/api/utilizatori", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(utilizatori)
        });

        const data = await postRes.json();
        console.log("RĂSPUNS", data);

    } catch (err) {
        console.error("EROARE", err);
    }
};

const verifica_cont = async () => {
    const id = document.getElementById("username").value;
    const pass = document.getElementById("password").value;
    const marker = document.getElementById("valid-status");

    marker.textContent = "Cererea se încarcă...";

    try {
        const res = await fetch("resurse/utilizatori.json");
        const text = await res.text();

        let utilizatori = [];
        try {
            utilizatori = JSON.parse(text);
        } catch (err) {
            alert("Eroare la citirea fișierului!");
            return;
        }

        const contGasit = utilizatori.find(cont => cont.username === id && cont.password === pass);

        if (contGasit) {
            marker.classList.remove("wrong");
            marker.textContent = "Cont corect";
        } else {
            marker.classList.add("wrong");
            marker.textContent = "Nu a fost găsit un cont";
        }

    } catch (err) {
        console.error("EROARE", err);
    }
};
