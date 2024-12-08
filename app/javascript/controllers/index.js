// Import and register all your controllers from the importmap under controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Register custom controllers
import MarketController from "./fantasy/market_controller"
import EventsController from "./fantasy/events_controller"

application.register("fantasy--market", MarketController)
application.register("fantasy--events", EventsController)
