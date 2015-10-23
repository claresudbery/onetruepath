using Nancy;
using OneTruePath.Domain;

namespace OneTruePath.API.Modules
{
    public class OneTruePathModule : NancyModule
    {
        public OneTruePathModule(IStoryNavigator storyNavigator)
        {
            Get["/truepath"] = parameters =>
            {
                string result = storyNavigator.Refresh();
                return result;
            };

            Get["/truepath/-"] = parameters =>
            {
                string result = storyNavigator.GetPreviousOptions();
                return result;
            };

            Get["/truepath/1"] = parameters =>
            {
                string result = storyNavigator.GetNextOptions(1);
                return result;
            };

            Get["/truepath/2"] = parameters =>
            {
                string result = storyNavigator.GetNextOptions(2);
                return result;
            };

            Get["/truepath/3"] = parameters =>
            {
                string result = storyNavigator.GetNextOptions(3);
                return result;
            };
        }
    }
}