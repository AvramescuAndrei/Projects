const incarcaPersoane = (xml) => {
    const table = document.createElement("table");
    table.id = "persoane_xml";

    const thead = document.createElement("thead");
    thead.innerHTML = "<tr></tr>";

    const tbody = document.createElement("tbody");
    const persoane = xml.querySelectorAll("persoane > persoana");

    if (!persoane.length) {
        console.warn("Nu există persoane în XML.");
        return;
    }

    const firstPers = persoane[0];
    for (const el of firstPers.children) {
        const elType = el.nodeName;
        thead.querySelector("tr").insertAdjacentHTML("beforeend", `<th>${elType}</th>`);
    }

    for (const persoana of persoane) {
        let rowHTML = "";
        for (const el of persoana.children) {
            const value = el.textContent;
            rowHTML += `<td>${value}</td>`;
        }
        tbody.insertAdjacentHTML("beforeend", `<tr>${rowHTML}</tr>`);
    }

    table.appendChild(thead);
    table.appendChild(tbody);
    document.getElementById("continut").appendChild(table);
    
    const loader = document.getElementById("loading_persoane");
    if (loader) loader.remove();
};

const getPersoane = async () => {
    try {
        const res = await fetch("resurse/persoane.xml");
        const text = await res.text();
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(text, "text/xml");
        incarcaPersoane(xmlDoc);
    } catch (err) {
        console.error("Eroare:", err);
    }
};

getPersoane();
