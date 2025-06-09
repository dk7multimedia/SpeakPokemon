<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Pokémon Speech Therapy Word Sheet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap" rel="stylesheet">
    <!-- Chosen Palette: Warm Neutrals & Subtle Accents -->
    <!-- Application Structure Plan: The application is structured as a single-page filterable dashboard. A persistent top navigation bar contains buttons for each phonetic category (e.g., 'P Sound', 'B Sound', 'Blends'). Below this, a dynamic grid displays the corresponding Pokémon names as interactive cards. This structure was chosen over a linear document format to allow speech therapists or users to instantly access specific word lists without scrolling, making practice sessions more efficient and targeted. The user flow is simple: click a filter, view the results. An 'All' button allows for easy browsing of the entire collection. -->
    <!-- Visualization & Content Choices: The source report's data is a list of words categorized by phonemes. The goal is to organize and inform. Therefore, instead of charts (which are unsuitable for this data), the primary presentation method is a dynamic, filterable grid of "word cards." Each card represents a Pokémon, with the target sound highlighted using a styled `<span>`. Images are dynamically loaded from Serebii.net using their Pokédex numbers where available, with a fallback to a generic text placeholder image. New features include AI-generated pronunciation tips and example sentences, which are displayed in a dedicated section below the grid. This provides immediate visual reinforcement and interactive content. The interaction is centered on the filter buttons and new AI generation buttons, which use JavaScript to toggle the visibility of the cards and trigger LLM calls based on their data attributes. This approach is direct, intuitive, and perfectly suited to the task of exploring a categorized word list and enhancing it with AI. -->
    <!-- CONFIRMATION: NO SVG graphics used. NO Mermaid JS used. -->
    <style>
        body {
            font-family: 'Inter', sans-serif;
        }
        .active-filter {
            background-color: #4f46e5 !important;
            color: #ffffff !important;
        }
    </style>
</head>
<body class="bg-stone-100 text-stone-800">

    <div class="container mx-auto p-4 sm:p-6 lg:p-8">
        <header class="text-center mb-8">
            <h1 class="text-3xl sm:text-4xl font-bold text-indigo-700">Interactive Pokémon Speech Therapy Tool</h1>
            <p class="mt-2 text-md text-stone-600 max-w-2xl mx-auto">Click on a sound category below to filter the list of Pokémon names. This tool is designed to make speech practice fun and engaging by using familiar characters.</p>
        </header>

        <nav id="filter-nav" class="mb-8 flex flex-wrap justify-center gap-2">
        </nav>

        <main id="word-grid" class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
        </main>

        <div id="llm-response-area" class="mt-8 p-6 bg-white rounded-lg shadow-lg hidden">
            <h2 id="llm-response-title" class="text-2xl font-bold text-indigo-700 mb-4"></h2>
            <p id="llm-response-content" class="text-lg text-stone-700"></p>
            <button id="close-llm-response" class="mt-4 px-4 py-2 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors">Close</button>
        </div>

    </div>

    <script>
        const pokemonData = [
            { name: "Pikachu", sound: "P", position: "Initial", dexNumber: "025" },
            { name: "Pidgey", sound: "P", position: "Initial", dexNumber: "016" },
            { name: "Poliwag", sound: "P", position: "Initial", dexNumber: "060" },
            { name: "Superior", sound: "P", position: "Medial" },
            { name: "Bulbasaur", sound: "B", position: "Initial", dexNumber: "001" },
            { name: "Bellsprout", sound: "B", position: "Initial", dexNumber: "069" },
            { name: "Bidoof", sound: "B", position: "Initial", dexNumber: "399" },
            { name: "Cubone", sound: "B", position: "Medial", dexNumber: "104" },
            { name: "Golbat", sound: "B", position: "Final", dexNumber: "042" },
            { name: "Mew", sound: "M", position: "Initial", dexNumber: "151" },
            { name: "Magnemite", sound: "M", position: "Initial", dexNumber: "081" },
            { name: "Mankey", sound: "M", position: "Initial", dexNumber: "056" },
            { name: "Turtwig", sound: "T", position: "Initial", dexNumber: "387" },
            { name: "Togepi", sound: "T", position: "Initial", dexNumber: "175" },
            { name: "Latias", sound: "T", position: "Medial", dexNumber: "380" },
            { name: "Staryu", sound: "T", position: "Medial", dexNumber: "120" },
            { name: "Dratini", sound: "D", position: "Initial", dexNumber: "147" },
            { name: "Diglett", sound: "D", position: "Initial", dexNumber: "050" },
            { name: "Nidoran", sound: "D", position: "Medial", dexNumber: "029" },
            { name: "Charizard", sound: "K", position: "Initial", dexNumber: "006" },
            { name: "Krabby", sound: "K", position: "Initial", dexNumber: "098" },
            { name: "Quagsire", sound: "K", position: "Initial", dexNumber: "195" },
            { name: "Squirtle", sound: "K", position: "Medial", dexNumber: "007" },
            { name: "Gengar", sound: "G", position: "Initial", dexNumber: "094" },
            { name: "Growlithe", sound: "G", position: "Initial", dexNumber: "058" },
            { name: "Gyarados", sound: "G", position: "Initial", dexNumber: "130" },
            { name: "Fennekin", sound: "F", position: "Initial", dexNumber: "653" },
            { name: "Flareon", sound: "F", position: "Initial", dexNumber: "136" },
            { name: "Froakie", sound: "F", position: "Initial", dexNumber: "656" },
            { name: "Jumpluff", sound: "F", position: "Medial", dexNumber: "189" },
            { name: "Vulpix", sound: "V", position: "Initial", dexNumber: "037" },
            { name: "Vaporeon", sound: "V", position: "Initial", dexNumber: "134" },
            { name: "Sylveon", sound: "V", position: "Medial", dexNumber: "700" },
            { name: "Squirtle", sound: "S", position: "Initial", dexNumber: "007" },
            { name: "Scyther", sound: "S", position: "Initial", dexNumber: "123" },
            { name: "Snorlax", sound: "S", position: "Initial", dexNumber: "143" },
            { name: "Pikachu", sound: "S", position: "Medial", dexNumber: "025" },
            { name: "Zubat", sound: "Z", position: "Initial", dexNumber: "041" },
            { name: "Zoroark", sound: "Z", position: "Initial", dexNumber: "571" },
            { name: "Zigzagoon", sound: "Z", position: "Initial", dexNumber: "263" },
            { name: "Charizard", sound: "Z", position: "Medial" },
            { name: "Shinx", sound: "Sh", position: "Initial", dexNumber: "403" },
            { name: "Shaymin", sound: "Sh", position: "Initial", dexNumber: "492" },
            { name: "Chikorita", sound: "Ch", position: "Initial", dexNumber: "152" },
            { name: "Charmander", sound: "Ch", position: "Initial", dexNumber: "004" },
            { name: "Pikachu", sound: "Ch", position: "Medial", dexNumber: "025" },
            { name: "Jigglypuff", sound: "J", position: "Initial", dexNumber: "039" },
            { name: "Jynx", sound: "J", position: "Initial", dexNumber: "124" },
            { name: "Jolteon", sound: "J", position: "Initial", dexNumber: "135" },
            { name: "Lucario", sound: "L", position: "Initial", dexNumber: "448" },
            { name: "Lapras", sound: "L", position: "Initial", dexNumber: "131" },
            { name: "Bulbasaur", sound: "L", position: "Medial", dexNumber: "001" },
            { name: "Rattata", sound: "R", position: "Initial", dexNumber: "019" },
            { name: "Rowlet", sound: "R", position: "Initial", dexNumber: "722" },
            { name: "Charizard", sound: "R", position: "Medial", dexNumber: "006" },
            { name: "Dratini", sound: "R", position: "Medial", dexNumber: "147" },
            { name: "Staryu", sound: "Blends", position: "st", dexNumber: "120" },
            { name: "Stoutland", sound: "Blends", position: "st", dexNumber: "508" },
            { name: "Krabby", sound: "Blends", position: "cr", dexNumber: "098" },
            { name: "Dratini", sound: "Blends", position: "dr", dexNumber: "147" },
            { name: "Dragonite", sound: "Blends", position: "dr", dexNumber: "149" },
            { name: "Growlithe", sound: "Blends", position: "gr", dexNumber: "058" },
            { name: "Flareon", sound: "Blends", position: "fl", dexNumber: "136" },
            { name: "Slakoth", sound: "Blends", position: "sl", dexNumber: "287" },
            { name: "Smeargle", sound: "Blends", position: "sm", dexNumber: "235" },
            { name: "Charizard", sound: "Multi", position: "3", dexNumber: "006" },
            { name: "Bulbasaur", sound: "Multi", position: "3", dexNumber: "001" },
            { name: "Jigglypuff", sound: "Multi", position: "3", dexNumber: "039" },
            { name: "Meganium", sound: "Multi", position: "4", dexNumber: "154" },
            { name: "Tyranitar", sound: "Multi", position: "4", dexNumber: "248" },
            { name: "Empoleon", sound: "Multi", position: "4", dexNumber: "395" },
        ];
        
        const soundCategories = {
            "P": "P Sound", "B": "B Sound", "M": "M Sound", "T": "T Sound",
            "D": "D Sound", "K": "K/C/Q Sound", "G": "G Sound", "F": "F Sound",
            "V": "V Sound", "S": "S Sound", "Z": "Z Sound", "Sh": "Sh Sound",
            "Ch": "Ch Sound", "J": "J Sound", "L": "L Sound", "R": "R Sound",
            "Multi": "Multisyllabic", "Blends": "Blends"
        };

        const navContainer = document.getElementById('filter-nav');
        const gridContainer = document.getElementById('word-grid');
        const llmResponseArea = document.getElementById('llm-response-area');
        const llmResponseTitle = document.getElementById('llm-response-title');
        const llmResponseContent = document.getElementById('llm-response-content');
        const closeLlmResponseBtn = document.getElementById('close-llm-response');

        closeLlmResponseBtn.addEventListener('click', () => {
            llmResponseArea.classList.add('hidden');
            llmResponseTitle.textContent = '';
            llmResponseContent.textContent = '';
        });

        function highlightSound(name, sound, position) {
            let highlightedName = name;
            let regex;

            try {
                switch (sound) {
                    case 'P': regex = /p/i; break;
                    case 'B': regex = /b/i; break;
                    case 'M': regex = /m/i; break;
                    case 'T': regex = /t/i; break;
                    case 'D': regex = /d/i; break;
                    case 'K': regex = /[kcq]/i; break;
                    case 'G': regex = /g/i; break;
                    case 'F': regex = /f/i; break;
                    case 'V': regex = /v/i; break;
                    case 'S': regex = /s/i; break;
                    case 'Z': regex = /z/i; break;
                    case 'Sh': regex = /sh/i; break;
                    case 'Ch': regex = /ch/i; break;
                    case 'J': regex = /j/i; break;
                    case 'L': regex = /l/i; break;
                    case 'R': regex = /r/i; break;
                    case 'Blends': regex = new RegExp(position, 'i'); break;
                    default: return name;
                }

                if (position === 'Initial') {
                    regex = new RegExp('^' + regex.source, 'i');
                }
                
                if (regex) {
                   highlightedName = name.replace(regex, `<span class="font-bold text-indigo-600">$&</span>`);
                }
            } catch (e) {
                return name; 
            }
            
            return highlightedName;
        }

        async function generateLLMContent(type, pokemonName, sound, position, buttonElement) {
            llmResponseArea.classList.remove('hidden');
            llmResponseTitle.textContent = 'Generating...';
            llmResponseContent.textContent = 'Please wait while the AI generates the content.';
            buttonElement.disabled = true;
            buttonElement.textContent = 'Generating...';

            let prompt = "";
            let title = "";

            if (type === 'tips') {
                title = `✨ Pronunciation Tips for ${pokemonName}`;
                prompt = `Provide concise and helpful pronunciation tips for the sound "${sound}" in the Pokémon name "${pokemonName}", considering its position as "${position}". Focus on practical advice for a speech therapy context.`;
            } else if (type === 'sentence') {
                title = `✨ Example Sentence for ${pokemonName}`;
                prompt = `Create a short, simple, and grammatically correct sentence that includes the Pokémon name "${pokemonName}". The sentence should ideally emphasize the sound "${sound}" if possible, but the primary goal is a clear example sentence.`;
            } else {
                llmResponseTitle.textContent = 'Error';
                llmResponseContent.textContent = 'Invalid LLM content type.';
                buttonElement.disabled = false;
                buttonElement.textContent = type === 'tips' ? '✨ Pronunciation Tips' : '✨ Example Sentence';
                return;
            }

            const payload = { contents: [{ role: "user", parts: [{ text: prompt }] }] };
            const apiKey = "";
            const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`;

            try {
                const response = await fetch(apiUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                const result = await response.json();

                if (result.candidates && result.candidates.length > 0 &&
                    result.candidates[0].content && result.candidates[0].content.parts &&
                    result.candidates[0].content.parts.length > 0) {
                    const text = result.candidates[0].content.parts[0].text;
                    llmResponseTitle.textContent = title;
                    llmResponseContent.textContent = text;
                } else {
                    llmResponseTitle.textContent = 'Generation Failed';
                    llmResponseContent.textContent = 'Could not generate content. Please try again.';
                    console.error('Gemini API response structure unexpected:', result);
                }
            } catch (error) {
                llmResponseTitle.textContent = 'Error';
                llmResponseContent.textContent = 'Failed to connect to the AI service. Please check your network connection.';
                console.error('Error calling Gemini API:', error);
            } finally {
                buttonElement.disabled = false;
                buttonElement.textContent = type === 'tips' ? '✨ Pronunciation Tips' : '✨ Example Sentence';
            }
        }

        function renderCards(filter = 'All') {
            gridContainer.innerHTML = '';
            const filteredData = filter === 'All' 
                ? pokemonData 
                : pokemonData.filter(p => p.sound === filter);

            filteredData.forEach(pokemon => {
                const card = document.createElement('div');
                card.className = 'word-card bg-white p-4 rounded-lg shadow-md flex flex-col items-center text-center transition-transform transform hover:scale-105';
                card.dataset.sound = pokemon.sound;
                
                let displayName = pokemon.name;
                if(filter !== 'All' && filter !== 'Multi'){
                     displayName = highlightSound(pokemon.name, pokemon.sound, pokemon.position);
                } else if (filter === 'Multi') {
                     displayName = `${pokemon.name} <span class="block text-xs text-stone-500">(${pokemon.position} syllables)</span>`
                }

                const serebiiImageUrl = pokemon.dexNumber
                    ? `https://www.serebii.net/pokemongo/pokemon/${pokemon.dexNumber}.png`
                    : `https://placehold.co/100x100/F5F5F5/6366F1?text=${pokemon.name.replace(/ /g, '+')}`;
                
                card.innerHTML = `
                    <img src="${serebiiImageUrl}" alt="${pokemon.name}" class="w-24 h-24 rounded-full mb-2 object-cover" onerror="this.onerror=null;this.src='https://placehold.co/100x100/F5F5F5/6366F1?text=${pokemon.name.replace(/ /g, '+')}';">
                    <p class="text-lg font-medium">${displayName}</p>
                    <div class="flex gap-2 mt-4">
                        <button class="llm-btn px-3 py-1 bg-indigo-500 text-white text-sm rounded-full hover:bg-indigo-600 transition-colors" data-type="tips" data-pokemon="${pokemon.name}" data-sound="${pokemon.sound}" data-position="${pokemon.position}">✨ Pronunciation Tips</button>
                        <button class="llm-btn px-3 py-1 bg-green-500 text-white text-sm rounded-full hover:bg-green-600 transition-colors" data-type="sentence" data-pokemon="${pokemon.name}" data-sound="${pokemon.sound}" data-position="${pokemon.position}">✨ Example Sentence</button>
                    </div>
                `;
                gridContainer.appendChild(card);
            });

            document.querySelectorAll('.llm-btn').forEach(button => {
                button.addEventListener('click', (event) => {
                    const type = event.target.dataset.type;
                    const pokemonName = event.target.dataset.pokemon;
                    const sound = event.target.dataset.sound;
                    const position = event.target.dataset.position;
                    generateLLMContent(type, pokemonName, sound, position, event.target);
                });
            });
        }

        function renderNav() {
            const filters = ['All', ...Object.keys(soundCategories)];
            filters.forEach(filterKey => {
                const button = document.createElement('button');
                button.className = 'filter-btn px-4 py-2 bg-white text-indigo-700 rounded-full shadow-sm hover:bg-indigo-100 transition-colors';
                button.textContent = filterKey === 'All' ? 'All Pokémon' : soundCategories[filterKey];
                button.dataset.filter = filterKey;

                if (filterKey === 'All') {
                    button.classList.add('active-filter');
                }

                button.addEventListener('click', () => {
                    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active-filter'));
                    button.classList.add('active-filter');
                    renderCards(filterKey);
                });

                navContainer.appendChild(button);
            });
        }

        document.addEventListener('DOMContentLoaded', () => {
            renderNav();
            renderCards();
        });

    </script>
</body>
</html>
