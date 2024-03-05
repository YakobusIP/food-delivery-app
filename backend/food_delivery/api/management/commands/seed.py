from typing import Any
from django.core.management.base import BaseCommand
from faker import Faker
from faker_food import FoodProvider
from ...models import Restaurant, Menu

class Command(BaseCommand):
    help = "Seed the database"

    def handle(self, *args: Any, **options: Any) -> str | None:
        faker = Faker()
        faker.add_provider(FoodProvider)

        # Generate restaurants

        #     image_urls = [
        #         "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fhokben.png?alt=media&token=2a065809-30a7-44f2-93fe-c516727955c6",
        #         "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fkfc.png?alt=media&token=afed4069-060c-43fe-9994-a2d484e329a7",
        #         "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fmcdonalds.png?alt=media&token=b83adc17-aae5-495f-8c9c-d87d8f134eda"
        #     ]

        # for _ in range(100):
        #     # Generate opening time
        #     opening_hour = faker.random_int(min=0, max=22)  # Up to 22 to leave room for closing time
        #     opening_minute = faker.random_int(min=0, max=59)
        #     opening_time = f"{opening_hour:02d}:{opening_minute:02d}"

        #     # Generate closing time by ensuring it's at least 1 hour after the opening
        #     closing_hour = faker.random_int(min=opening_hour + 1, max=23)
        #     closing_minute = faker.random_int(min=0, max=59)
        #     closing_time = f"{closing_hour:02d}:{closing_minute:02d}"

        #     Restaurant.objects.create(
        #         name=faker.name(),
        #         address=faker.address(),
        #         phone_number=faker.unique.phone_number(),
        #         email=faker.unique.email(),
        #         rating=faker.random_int(min=0, max=50) / 10.0,
        #         delivery_radius=faker.random_int(min=1, max=10),
        #         opening_time=opening_time,
        #         closing_time=closing_time,
        #         image_path=faker.random_element(image_urls)
        #     )

        # Generate restaurants menu

        restaurand_ids = list(Restaurant.objects.values_list("id", flat=True))

        image_urls = [
            "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fchicken.jpg?alt=media&token=c0541121-dbcf-49d3-a636-fb957fa4f865",
            "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fsalad.jpg?alt=media&token=7e67ef49-44e3-4b00-86bc-890cbb449a53",
            "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fsteak.jpg?alt=media&token=b23780a7-f7e5-4964-a68c-1324f6743806"
        ]

        for _ in range(2000):
            restaurant_id = faker.random_element(restaurand_ids)
            category = faker.random_element(Menu.FoodCategory.choices)[0]

            Menu.objects.create(
                restaurant_id=restaurant_id, 
                name=faker.dish(), 
                description=faker.dish_description(),
                price=faker.pyint(min_value=10000, max_value=200000, step=100),
                category=category,
                image_path=faker.random_element(image_urls)
            )
        
        self.stdout.write(self.style.SUCCESS("Database seed successful"))