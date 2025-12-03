from dataclasses import dataclass\nfrom typing import Optional\n\n@dataclass\nclass Task:\n    id: str\n    title: str\n    description: Optional[str] = None\n    status: str = "incomplete"
